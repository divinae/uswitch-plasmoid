# uSwitch: notes for AI agents

USwitch ("USwitcher" in the widget list) is a modified Plasma 6 User Switcher plasmoid: app
shortcuts you pick at the top of the popup, then your user and sessions, New Session, Lock
Screen, Sleep and Leave. Plugin Id `com.dv.uswitcher` (`package/metadata.json`), plus a small C++
QML plugin `com.dv.uswitcher.private` (`AppsModel`). Owner Jakub Lipiński (GitHub `divinae`).
Code at https://github.com/divinae/uswitch-plasmoid (moved from GitLab, hence the old
`Merge branch ... into 'master'` commits); published on the KDE Store at
https://store.kde.org/p/2135898/. Push to `origin` (`git@github.com:divinae/uswitch-plasmoid.git`),
branch `master`, committed directly. The local `refactor/plasma-6.8` branch is already merged.

## Layout

- `package/metadata.json`: KPlugin metadata; `Version` is the version (CMake reads Id and Version
  from it). `X-Plasma-API-Minimum-Version` 6.0, but README says tested on Plasma 6.8 and CMake
  requires Qt 6.8 / KF 6.14.
- `package/contents/config/main.xml`: groups `General` (`showFace`, `showSett`, `showName`,
  `showFullName`, `showTechnicalInfo`, `icon`, `iconPositionRight`) and `Apps` (`appList`, a JSON
  string `[["foo.desktop", {"iconName": "bar"}], ...]`). `config.qml`: pages General and Apps.
- `package/contents/ui/`: `main.qml` (`PlasmoidItem`, compact + full representation, uses
  `org.kde.plasma.private.sessions` `SessionManagement`/`SessionsModel`), `configGeneral.qml`,
  `configApps.qml` (writes `cfg_appList` as JSON), `ConfigIcon.qml`, `ListDelegate.qml`,
  `ActionListDelegate.qml`, `UserListDelegate.qml`.
- `plugin/`: `appsmodel.{h,cpp}` (KService-backed list model, `launch()` via
  `KIO::ApplicationLauncherJob`, reloads on KSycoca changes; `allApplications` mode lists every
  app for the picker), `CMakeLists.txt` (`ecm_add_qml_module(... GENERATE_PLUGIN_SOURCE)`).
- `CMakeLists.txt`: options `BUILD_PLUGIN` (ON), `INSTALL_PLASMOID` (ON, `plasma_install_package`),
  `PACKAGE_PLASMOID` (OFF; zips `package/` to `uswitch-v<Version>.plasmoid` in the repo root).
- `screenshots/`: README images. No tests, no CHANGELOG, no CI.
- Not tracked, not yours to touch: `build/` (the user's CMake build dir, gitignored),
  `uswitch-v*.plasmoid` (gitignored), `docs/kde-store.md` (store page text, untracked; the user
  updates its Version/Changelog fields per release).

## Build, run, test

From README and `CMakeLists.txt`:

```sh
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr   # README; needs sudo to install
cmake --build build
sudo cmake --install build
systemctl --user restart plasma-plasmashell
```

The user's own `build/` is configured with `CMAKE_INSTALL_PREFIX=~/.local` (no sudo): the
plasmoid lands in `~/.local/share/plasma/plasmoids/com.dv.uswitcher/`, the plugin in
`~/.local/lib/qml/com/dv/uswitcher/private/`. plasmashell finds it because
`~/.config/plasma-workspace/env/kara.sh` (from the kara widget) adds `~/.local/lib/qml` to
`QML2_IMPORT_PATH`. So locally: `cmake --build build && cmake --install build`, then restart
plasmashell (only when the user asks; it restarts the desktop). `plasmawindowed com.dv.uswitcher`
works for a quick look if the same import path is set in the environment. A QML-only change still
needs the install step (plasmoid files are copied, not linked). Logs:
`journalctl --user -b --since "-15min" | grep -i -E "uswitch|plasmashell"`.
`-DPACKAGE_PLASMOID=ON` builds the QML-only `.plasmoid` (useless without the plugin).
No test suite or linter is set up; at least build (catches C++ errors) and, for QML, run
`qmllint` if wanted.

## Conventions

- QML: 4-space indent, Qt 6 unversioned imports with aliases (`as Kirigami`,
  `as PlasmaComponents3`, `as USwitcher`), `root.` qualified property access.
- C++: KDE style (4 spaces, braces on own line for functions, `Q_SIGNALS`, `m_` members), C++20,
  `KDE_COMPILERSETTINGS_LEVEL` 5.82.
- i18n: no own catalog. Strings that exist in Plasma reuse its translations via `i18nd`/`i18ndc`
  with `userSwitcherDomain` (`plasma_applet_org.kde.plasma.userswitcher`) or `lookAndFeelDomain`
  (`plasma_lookandfeel_org.kde.lookandfeel`), so the exact msgid/context must match Plasma's.
  Other strings use plain `i18n`/`i18nc` (shown in English).
- Licensing: GPL-2.0-or-later per file, as upstream User Switcher. Newer files use SPDX headers
  (`SPDX-FileCopyrightText: 2026 Jakub Lipiński <lipinski.j@pm.me>`); files from Kai Uwe Broulik
  keep his copyright (some still in the old long-text form); add yours, don't remove his.
  `LICENSE` holds GPL-3.0 text (README explains).
- Versioning: semver in `metadata.json` only; tags are bare `X.Y.Z` (no `v`, latest `2.1.0`).
  The version bump went into the feature commit ("Bump version to 2.1.0"). Release changelog text
  lives only in `docs/kde-store.md` and on the store page.
- Commits: recent ones are a capitalized plain-English subject without prefix ("Fix plasmoid on
  Plasma 6.8, refactor app shortcuts"), body as `- ` bullets explaining what and why, and
  `Co-Authored-By:` when AI-assisted. Older history mixes `fix:`/`feat:` prefixes.

## Gotchas

- `main.qml` starts with a UTF-8 BOM; leave it.
- `Kirigami.Theme.smallestFont` and `Kirigami.Theme.mSize()` don't exist; using them broke panel
  sizing before 2.1.0. Compact sizing is copied from Digital Clock; vertical panels are supported.
- The Plasma5Support "apps" engine and the old OpenUrlJob helper were replaced by `AppsModel`;
  don't reintroduce data engines.
- Sleep/Leave hide when `SessionManagement` says unsupported; Leave calls
  `requestLogoutPrompt()` (shows all options since Plasma 6.1).
- Config: entries of uninstalled apps are kept (shown "(not installed)"), duplicates prevented,
  no spurious "changed" state on load; keep that when editing `configApps.qml`.
- A `.plasmoid` alone can't load (needs the plugin); the store gets the source tarball
  `https://github.com/divinae/uswitch-plasmoid/archive/refs/tags/<version>.tar.gz`.
- README's install says `cd uswitch` after cloning; the directory is `uswitch-plasmoid`.

## Related

- `.github/FUNDING.yml` (Ko-fi `divinae4535`) and the README layout (badges, "Why you'll like
  it", Support, Bugs) match Taskline (`../taskline-plasmoid`) and the other `divinae` widgets.
- The `~/.local/lib/qml` import path comes from the kara widget's env script (`../kara-plasmoid`
  is in the same folder). No shared code with the sibling widgets is evident.
