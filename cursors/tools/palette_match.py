#!/usr/bin/env python3
"""Match every Oxygen cursor variant against the DarkGold (Harbor Dark) palette.

Reads cursors/<variant>/cursors/left_ptr (an Xcursor binary), takes the largest
image, clusters its opaque pixels, and compares the dominant colours to the
palette with CIEDE2000. Also measures WCAG contrast against the #1B1B1B
background so a cursor that disappears on the desktop gets flagged.

Standard library only.

  python3 cursors/tools/palette_match.py              # table on stdout
  python3 cursors/tools/palette_match.py --markdown   # same, as a Markdown table
  python3 cursors/tools/palette_match.py --swatches   # also write assets/cursors/*.png
  python3 cursors/tools/palette_match.py --suggest    # print tiers.tsv lines for the measured tiers

The tiers used by install.sh --list live in cursors/tiers.tsv. This script only
suggests them; edit that file by hand to override a tier.
"""
import argparse
import math
import struct
import sys
import zlib
from pathlib import Path

CURSORS = Path(__file__).resolve().parent.parent
REPO = CURSORS.parent
SWATCH_DIR = REPO / "assets" / "cursors"

BACKGROUND = "#1B1B1B"
PALETTE = {
    "Background": "#1B1B1B",
    "Parchment": "#EFEBDC",   # Foreground
    "Cream": "#E1CE98",
    "Gold": "#C0AF7F",
    "Brass": "#A99B7A",
    "Salmon": "#E58980",
    "Coral": "#E75A50",
    "Error": "#F44336",
    "Slate": "#77838A",
    "Dim": "#6D6D6D",
    "Olive": "#817F68",
}
WARM = {"Parchment", "Cream", "Gold", "Brass"}
ACCENT = {"Salmon", "Coral", "Error"}

# thresholds (CIEDE2000 units / WCAG ratio)
NEAR = 15.0          # body within this of a warm or accent colour -> that tier
NEUTRAL_CHROMA = 12  # body chroma (Lab C*) below this counts as grey / white / black
WARM_MIN_CHROMA = 5  # a "warm" body needs at least this much colour, or it is just grey
WARM_HUE = (60, 110) # Lab hue range (degrees) of the gold / cream family
LOUD_CHROMA = 25     # an outline this colourful that is off-palette gets flagged
SHARE = 0.2          # clusters covering at least this much of the cursor count
LOW_CONTRAST = 3.0   # below this against #1B1B1B the cursor is hard to see

XCURSOR_IMAGE = 0xFFFD0002


# --- Xcursor ---------------------------------------------------------------

def read_xcursor(path):
    """Return (width, height, [(r, g, b, a), ...]) for the largest image, first frame."""
    data = path.read_bytes()
    magic, _hsize, _version, ntoc = struct.unpack_from("<4sIII", data, 0)
    if magic != b"Xcur":
        raise ValueError(f"{path}: not an Xcursor file")
    best = None
    for i in range(ntoc):
        ctype, subtype, pos = struct.unpack_from("<III", data, 16 + 12 * i)
        if ctype != XCURSOR_IMAGE:
            continue
        if best is None or subtype > best[0]:
            best = (subtype, pos)
    if best is None:
        raise ValueError(f"{path}: no image chunks")
    pos = best[1]
    _hdr, _t, _s, _v, w, h, _xhot, _yhot, _delay = struct.unpack_from("<9I", data, pos)
    raw = struct.unpack_from(f"<{w * h}I", data, pos + 36)
    pixels = []
    for argb in raw:
        a = argb >> 24
        r, g, b = (argb >> 16) & 255, (argb >> 8) & 255, argb & 255
        if a:  # Xcursor pixels are premultiplied
            r, g, b = (min(255, round(c * 255 / a)) for c in (r, g, b))
        pixels.append((r, g, b, a))
    return w, h, pixels


# --- colour maths ----------------------------------------------------------

def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#{:02X}{:02X}{:02X}".format(*(round(c) for c in rgb))


def _linear(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def rgb_to_lab(rgb):
    r, g, b = (_linear(c) for c in rgb)
    x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047
    y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b
    z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883

    def f(t):
        return t ** (1 / 3) if t > 216 / 24389 else (24389 / 27 * t + 16) / 116

    fx, fy, fz = f(x), f(y), f(z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def chroma(lab):
    return math.hypot(lab[1], lab[2])


def hue(lab):
    return math.degrees(math.atan2(lab[2], lab[1])) % 360


def ciede2000(lab1, lab2):
    L1, a1, b1 = lab1
    L2, a2, b2 = lab2
    C1, C2 = math.hypot(a1, b1), math.hypot(a2, b2)
    Cb7 = ((C1 + C2) / 2) ** 7
    G = 0.5 * (1 - math.sqrt(Cb7 / (Cb7 + 25 ** 7)))
    a1p, a2p = (1 + G) * a1, (1 + G) * a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360 if C1p else 0.0
    h2p = math.degrees(math.atan2(b2, a2p)) % 360 if C2p else 0.0
    dLp = L2 - L1
    dCp = C2p - C1p
    if C1p * C2p == 0:
        dhp = 0.0
    elif abs(h2p - h1p) <= 180:
        dhp = h2p - h1p
    elif h2p - h1p > 180:
        dhp = h2p - h1p - 360
    else:
        dhp = h2p - h1p + 360
    dHp = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dhp / 2))
    Lbp = (L1 + L2) / 2
    Cbp = (C1p + C2p) / 2
    if C1p * C2p == 0:
        hbp = h1p + h2p
    elif abs(h1p - h2p) <= 180:
        hbp = (h1p + h2p) / 2
    elif h1p + h2p < 360:
        hbp = (h1p + h2p + 360) / 2
    else:
        hbp = (h1p + h2p - 360) / 2
    T = (1 - 0.17 * math.cos(math.radians(hbp - 30))
         + 0.24 * math.cos(math.radians(2 * hbp))
         + 0.32 * math.cos(math.radians(3 * hbp + 6))
         - 0.20 * math.cos(math.radians(4 * hbp - 63)))
    dtheta = 30 * math.exp(-(((hbp - 275) / 25) ** 2))
    Cbp7 = Cbp ** 7
    Rc = 2 * math.sqrt(Cbp7 / (Cbp7 + 25 ** 7))
    Sl = 1 + 0.015 * (Lbp - 50) ** 2 / math.sqrt(20 + (Lbp - 50) ** 2)
    Sc = 1 + 0.045 * Cbp
    Sh = 1 + 0.015 * Cbp * T
    Rt = -math.sin(math.radians(2 * dtheta)) * Rc
    return math.sqrt((dLp / Sl) ** 2 + (dCp / Sc) ** 2 + (dHp / Sh) ** 2
                     + Rt * (dCp / Sc) * (dHp / Sh))


def luminance(rgb):
    r, g, b = (_linear(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(rgb1, rgb2):
    l1, l2 = sorted((luminance(rgb1), luminance(rgb2)), reverse=True)
    return (l1 + 0.05) / (l2 + 0.05)


PALETTE_LAB = {name: rgb_to_lab(hex_to_rgb(h)) for name, h in PALETTE.items()}
BG_RGB = hex_to_rgb(BACKGROUND)


def nearest(lab, names=None):
    names = names or PALETTE_LAB.keys()
    return min(((n, ciede2000(lab, PALETTE_LAB[n])) for n in names), key=lambda x: x[1])


# --- clustering ------------------------------------------------------------

def clusters(pixels, merge=10.0, min_alpha=250):
    """Group opaque pixels into colour clusters. Returns [(rgb, share), ...] big first."""
    buckets = {}
    for r, g, b, a in pixels:
        if a < min_alpha:
            continue
        key = (r >> 3, g >> 3, b >> 3)
        s = buckets.setdefault(key, [0, 0, 0, 0])
        s[0] += r
        s[1] += g
        s[2] += b
        s[3] += 1
    total = sum(s[3] for s in buckets.values()) or 1
    groups = []  # [sum_r, sum_g, sum_b, n, lab]
    for s in sorted(buckets.values(), key=lambda s: -s[3]):
        rgb = (s[0] / s[3], s[1] / s[3], s[2] / s[3])
        lab = rgb_to_lab(rgb)
        for g in groups:
            if ciede2000(lab, g[4]) < merge:
                g[0] += s[0]
                g[1] += s[1]
                g[2] += s[2]
                g[3] += s[3]
                break
        else:
            groups.append([s[0], s[1], s[2], s[3], lab])
    out = [((g[0] / g[3], g[1] / g[3], g[2] / g[3]), g[3] / total) for g in groups]
    return sorted(out, key=lambda x: -x[1])


def body_and_outline(cl):
    """Body = biggest cluster; outline = the biggest cluster clearly darker or lighter."""
    body = cl[0][0]
    bl = rgb_to_lab(body)[0]
    for rgb, share in cl[1:]:
        if share >= 0.05 and abs(rgb_to_lab(rgb)[0] - bl) > 25:
            return body, rgb
    return body, None


# --- analysis --------------------------------------------------------------

def analyse(variant_dir):
    w, h, px = read_xcursor(variant_dir / "cursors" / "left_ptr")
    cl = clusters(px)
    body, outline = body_and_outline(cl)
    lab = rgb_to_lab(body)
    near_name, near_de = nearest(lab)
    warm = nearest(lab, WARM)
    # red cursors are often a dark red body with a salmon highlight, so look at
    # every large cluster for the accent match, not just the body
    acc = min((nearest(rgb_to_lab(rgb), ACCENT) for rgb, share in cl if share >= SHARE),
              key=lambda x: x[1])
    c_body = contrast(body, BG_RGB)
    c_best = max(contrast(rgb, BG_RGB) for rgb, share in cl if share >= SHARE)
    is_warm = chroma(lab) >= WARM_MIN_CHROMA and WARM_HUE[0] <= hue(lab) <= WARM_HUE[1]

    flags = []
    if outline:
        olab = rgb_to_lab(outline)
        oname, ode = nearest(olab)
        if chroma(olab) > LOUD_CHROMA and ode > NEAR:
            flags.append(f"outline {rgb_to_hex(outline)} off-palette")
    if chroma(lab) > chroma(PALETTE_LAB["Cream"]) + 15 and is_warm:
        flags.append(f"more saturated than Cream (C* {chroma(lab):.0f} vs {chroma(PALETTE_LAB['Cream']):.0f})")
    if c_best < LOW_CONTRAST:
        flags.append(f"blends into bg ({c_best:.1f}:1 at best)")
    elif c_body < LOW_CONTRAST:
        flags.append(f"dark body {c_body:.1f}:1, outline carries it ({c_best:.1f}:1)")

    if is_warm and warm[1] <= NEAR:
        tier, why = "best", f"{warm[0]} ΔE {warm[1]:.1f}"
    elif acc[1] <= NEAR:
        tier, why = "accent", f"{acc[0]} ΔE {acc[1]:.1f}"
    elif chroma(lab) < NEUTRAL_CHROMA and not any("off-palette" in f for f in flags):
        tier, why = "neutral", f"grey (C* {chroma(lab):.0f}), nearest {near_name} ΔE {near_de:.1f}"
    else:
        tier, why = "off", f"nearest {near_name} ΔE {near_de:.1f}"

    return {
        "name": variant_dir.name,
        "size": w,
        "pixels": px,
        "clusters": cl,
        "body": body,
        "outline": outline,
        "tier": tier,
        "why": why,
        "nearest": (near_name, near_de),
        "contrast": c_body,
        "contrast_best": c_best,
        "flags": flags,
    }


# --- PNG swatches ----------------------------------------------------------

def write_png(path, w, h, rows):
    """rows: list of h lists of (r, g, b) tuples."""
    raw = b"".join(b"\x00" + bytes(c for px in row for c in px) for row in rows)

    def chunk(tag, body):
        c = struct.pack(">I", len(body)) + tag + body
        return c + struct.pack(">I", zlib.crc32(tag + body) & 0xFFFFFFFF)

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 9))
           + chunk(b"IEND", b""))
    path.write_bytes(png)


def swatch(result, path):
    """Cursor on the #1B1B1B background, then colour bars for body and outline."""
    size, px = result["size"], result["pixels"]
    pad, bar = 8, 24
    colours = [result["body"]] + ([result["outline"]] if result["outline"] else [])
    w = size + 2 * pad + bar * len(colours) + pad
    h = size + 2 * pad
    rows = []
    for y in range(h):
        row = []
        for x in range(w):
            c = BG_RGB
            cx, cy = x - pad, y - pad
            if 0 <= cx < size and 0 <= cy < size:
                r, g, b, a = px[cy * size + cx]
                c = tuple(round(v * a / 255 + bg * (255 - a) / 255) for v, bg in zip((r, g, b), BG_RGB))
            bx = x - (size + 2 * pad)
            if 0 <= bx < bar * len(colours) and pad <= y < h - pad:
                c = tuple(round(v) for v in colours[bx // bar])
            row.append(c)
        rows.append(row)
    write_png(path, w, h, rows)


# --- output ----------------------------------------------------------------

TIER_ORDER = ["best", "accent", "neutral", "off"]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--markdown", action="store_true", help="print a Markdown table")
    ap.add_argument("--swatches", action="store_true", help=f"write PNGs to {SWATCH_DIR.relative_to(REPO)}/")
    ap.add_argument("--suggest", action="store_true", help="print tiers.tsv lines")
    args = ap.parse_args()

    variants = sorted(p for p in CURSORS.glob("Oxygen-*") if (p / "cursors" / "left_ptr").exists())
    if not variants:
        sys.exit("no Oxygen-* variants found next to tools/")
    results = [analyse(v) for v in variants]
    results.sort(key=lambda r: (TIER_ORDER.index(r["tier"]), r["name"]))

    if args.suggest:
        print("# variant\ttier   (best | accent | neutral | off)")
        for r in results:
            print(f"{r['name']}\t{r['tier']}")
        return

    if args.swatches:
        SWATCH_DIR.mkdir(parents=True, exist_ok=True)
        for r in results:
            swatch(r, SWATCH_DIR / f"{r['name']}.png")

    if args.markdown:
        print("| Variant | Tier | Body | Outline | Contrast on #1B1B1B | Why |")
        print("| ------- | ---- | ---- | ------- | ------------------- | --- |")
    else:
        print(f"{'variant':30} {'tier':8} {'body':8} {'outline':8} {'contr':>6}  why / flags")
    for r in results:
        body = rgb_to_hex(r["body"])
        outl = rgb_to_hex(r["outline"]) if r["outline"] else "-"
        why = r["why"] + ("; " + ", ".join(r["flags"]) if r["flags"] else "")
        if args.markdown:
            print(f"| {r['name']} | {r['tier']} | `{body}` | `{outl}` | {r['contrast']:.1f}:1 | {why} |")
        else:
            print(f"{r['name']:30} {r['tier']:8} {body:8} {outl:8} {r['contrast']:5.1f}:1  {why}")


if __name__ == "__main__":
    main()
