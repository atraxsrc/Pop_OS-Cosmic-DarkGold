# Firefox — DarkGold / Harbor Dark

Firefox chrome matching the COSMIC DarkGold rice. Same layout as Monochrome
Dark and Cosmic Night, with gray / lime swapped for gold and charcoal.

## Palette

| Hex       | Role                      |
|-----------|---------------------------|
| `#1B1B1B` | Frame, page chrome        |
| `#252525` | Panels, menus             |
| `#2E2E2E` | Hover / active row        |
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
│   ├── userChrome.css    browser UI: rounded corners, solid menu hover
│   └── userContent.css   new tab page: accent colour only
└── install.sh            copies chrome/ into the default profile
```

No WebExtension theme package in this repo. Use Firefox's built-in Dark theme
plus these stylesheets.

## Setup

```bash
./install.sh
```

Copies `chrome/` into your `*.default-release` profile, backs up anything it
replaces, and adds the required pref to `user.js`. Then **fully restart**
Firefox — `userChrome.css` is parsed only at startup.

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
  the right-click panel look detached. Hover is a solid `#2E2E2E` row, not an
  inset ring.
- **`[_moz-menuactive="true"]` is required.** Firefox marks the active
  context-menu row with that attribute, not only `:hover`.
- **`userContent.css` sets colour variables only.** No size or position rules
  on new-tab tiles.

## License

MIT, same as the rest of the repo.
