# USwitch for Plasma 6

[![KDE Store](https://img.shields.io/badge/KDE%20Store-USwitch-1d99f3?logo=kde&logoColor=white)](https://store.kde.org/p/2135898/)
[![License](https://img.shields.io/badge/license-GPL--2.0--or--later-blue)](#license)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white)](https://ko-fi.com/divinae4535)

**Your session menu, with your apps in it.** A modified version of Plasma's
[User Switcher](https://invent.kde.org/plasma/kdeplasma-addons/-/tree/master/applets/userswitcher):
the apps you open most, your session and Lock, Sleep and Leave, one click from the panel.

| | |
| --- | --- |
| ![The popup](screenshots/Screenshot_20240308_084653.png) | ![The settings](screenshots/Screenshot_20240308_084708.png) |
| The popup: app shortcuts, the session, Lock, Sleep, Leave | The settings |

### Why you'll like it

- 🚀 **Your apps first.** The applications you pick (System Monitor, Info Center, System
  Settings… or any other) at the top of the popup.
- 🔒 **The session in one place.** Your user, a new session, **Lock Screen**, **Sleep** and
  **Leave…**, as Plasma's own widget has them.
- 🎨 **A panel icon of your choice.** Your name, your picture, an icon (any, also an image file),
  or a name with either, on the left or the right; full name or login name.
- ⌨️ **A keyboard shortcut** to open it, from the widget's settings.

## Install

USwitch comes with a small QML plugin (`com.dv.uswitcher.private`, C++) for its app list, so it's
built from source. The [KDE Store page](https://store.kde.org/p/2135898/) has its releases and
comments.

**1. The build tools and libraries.** On Arch:

```sh
sudo pacman -S --needed base-devel cmake extra-cmake-modules qt6-base qt6-declarative \
    kio kjobwidgets kservice libplasma
```

Elsewhere, the same under your distribution's names: CMake, extra-cmake-modules, Qt 6 (Core,
Qml), KF6 KIO, JobWidgets and Service, libplasma.

**2. Build and install:**

```sh
git clone https://github.com/divinae/uswitch-plasmoid.git
cd uswitch
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
```

**3. Restart Plasma** (`systemctl --user restart plasma-plasmashell`) and add **USwitcher** to a
panel: right click the panel > Add or Manage Widgets.

`-DPACKAGE_PLASMOID=ON` also builds a `.plasmoid` archive: the QML only, the plugin still has to be
installed as above.

## Requirements

- Plasma 6 (tested on 6.8), Qt 6.8 or later, KDE Frameworks 6.14 or later
- To build: CMake, extra-cmake-modules, and the KIO, KService and KJobWidgets development packages

## Support

If USwitch is useful to you, you can buy me a coffee on [Ko-fi](https://ko-fi.com/divinae4535).
That goes to this version's maintainer, not to the authors of Plasma's User Switcher it's based
on.

## Bugs and ideas

Report them in [GitHub Issues](https://github.com/divinae/uswitch-plasmoid/issues): your distribution, the
Plasma version, the widget's version, and for a problem its log. Do what goes wrong, then right
after:

```sh
journalctl --user -b --since "-15min" | grep -i -E "uswitch|plasmashell" > uswitch.log
```

Look it over before attaching `uswitch.log`.

## License

GPL-2.0-or-later, like Plasma's User Switcher it's based on (each file's header). `LICENSE` holds
the GPL-3.0 text, which "or later" allows.
