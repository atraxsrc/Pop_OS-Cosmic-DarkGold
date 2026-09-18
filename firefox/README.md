# Firefox - DarkGold / Harbor Dark

Firefox chrome matching the COSMIC DarkGold rice. Same layout as Monochrome
Dark and Cosmic Night, with gray / lime swapped for gold and charcoal.

Two layers, use one or both:

1. **Theme (colours):** the [harbordark](https://addons.mozilla.org/en-US/firefox/addon/harbordark/)
   add-on colours the toolbar, tabs and frame. This is the main look.
2. **Stylesheets (optional, this folder):** `userChrome.css` / `userContent.css`
   add rounded corners, gold menu hover, gold accents and a blank new-tab
   grid on top of whatever theme is active.

The stylesheets are written to sit on top of harbordark. They also work with
Firefox's built-in Dark theme if you would rather not install the add-on.

## Palette

| Hex       | Role                      |
|-----------|---------------------------|
| `#1B1B1B` | Frame, page chrome        |
| `#252525` | Panels, menus             |
| `#3D382C` | Menu hover row            |
| `#4A4334` | Menu pressed row          |
| `#3D3D3D` | Separators, menu border   |
| `#6d6d6d` | Muted text                |
| `#C0AF7F` | Accent, URL bar border    |
| `#a99b7a` | Secondary border / links  |
| `#E1CE98` | Body text                 |
| `#efebdc` | Hover text                |

## Structure

```
firefox/
├── chrome/
│   ├── userChrome.css    browser UI: rounded corners, gold menu hover
│   └── userContent.css   new tab page: gold accents, blank shortcut tiles
└── install.sh            copies chrome/ into the default profile
```

No WebExtension theme package in this repo; the theme layer is the
harbordark add-on linked above.

## Setup

```bash
./install.sh
```

Copies `chrome/` into your `*.default-release` profile, backs up anything it
replaces, and adds the required pref to `user.js`. Then **fully restart**
Firefox. `userChrome.css` is parsed only at startup.

Manual equivalent:

1. `about:config` → `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
2. `about:support` → Profile Directory → Open Directory
3. Copy `chrome/` in
4. Restart

To undo: delete the two files and restart, or run the Monochrome / Tokyo Night
`firefox/install.sh` to switch back.

## Notes

- **Never set `--panel-*` or `--arrowpanel-*` on `:root`.** Those variables leak
  into the toolbar and blank the URL bar. They stay on the popup elements.
- **Context menus do not get an extra element border.** A second stroke made
  the right-click panel look detached. Hover is a gold-tinted `#3D382C` row
  with a 3px gold rail on the left, not a full ring. (The old `#2E2E2E` was
  almost invisible on `#252525`.)
- **Native menu styling is switched off** (`appearance: none`) on menus and
  menu rows. Without it the COSMIC/GTK hover paints over the colours above.
- **`[_moz-menuactive="true"]` is required.** Firefox marks the active
  context-menu row with that attribute, not only `:hover`.
- **`userContent.css` is colours plus one hide rule.** It sets accent / focus /
  link colours and hides shortcut artwork (`opacity: 0`) so the new-tab tiles
  stay blank. No size or position rules on the tiles.

## License

MIT, same as the rest of the repo.
