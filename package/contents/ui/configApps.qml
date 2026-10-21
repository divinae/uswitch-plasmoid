/*
 *  SPDX-FileCopyrightText: 2026 Jakub Lipiński <lipinski.j@pm.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kcmutils as KCM

import com.dv.uswitcher.private as USwitcher

KCM.ScrollViewKCM {
    id: page

    property string cfg_appList
    property string cfg_appListDefault

    // Prevents saving while the list is being populated
    property bool loaded: false

    ListModel {
        id: userAppsModel
        onDataChanged: page.saveApps()
        onCountChanged: page.saveApps()
        onRowsMoved: page.saveApps()
    }

    USwitcher.AppsModel {
        id: configuredApps
    }

    USwitcher.AppsModel {
        id: allApps
        allApplications: true
    }

    Component.onCompleted: {
        configuredApps.appList = cfg_appList;
        for (let i = 0; i < configuredApps.count; i++) {
            userAppsModel.append(configuredApps.get(i));
        }
        loaded = true;
    }

    view: ListView {
        id: userAppList
        clip: true
        model: userAppsModel

        delegate: ItemDelegate {
            width: ListView.view.width
            down: false

            contentItem: RowLayout {
                ConfigIcon {
                    value: model.iconName
                    defaultValue: model.defaultIconName
                    onValueChanged: model.iconName = value
                }
                Label {
                    text: model.available ? model.name : i18nc("@info", "%1 (not installed)", model.name)
                    elide: Text.ElideRight
                    enabled: model.available
                    Layout.fillWidth: true
                }
                ToolButton {
                    icon.name: "arrow-up"
                    enabled: index > 0
                    onClicked: userAppsModel.move(index, index - 1, 1)
                }
                ToolButton {
                    icon.name: "arrow-down"
                    enabled: index < userAppsModel.count - 1
                    onClicked: userAppsModel.move(index, index + 1, 1)
                }
                ToolButton {
                    icon.name: "edit-delete-remove"
                    onClicked: userAppsModel.remove(index)
                }
            }
        }
    }

    footer: RowLayout {
        ComboBox {
            id: appSelector
            Layout.fillWidth: true
            editable: true
            textRole: "name"
            currentIndex: -1
            model: allApps
            onAccepted: page.addSelectedApp()
        }
        Button {
            icon.name: "list-add"
            enabled: appSelector.find(appSelector.editText) !== -1
            onClicked: page.addSelectedApp()
        }
    }

    function addSelectedApp() {
        const row = appSelector.find(appSelector.editText);
        if (row === -1) {
            return;
        }
        const app = allApps.get(row);
        for (let i = 0; i < userAppsModel.count; i++) {
            if (userAppsModel.get(i).menuId === app.menuId) {
                return;
            }
        }
        userAppsModel.append(app);
        appSelector.currentIndex = -1;
        appSelector.editText = "";
    }

    function saveApps() {
        if (!loaded) {
            return;
        }
        const apps = [];
        for (let i = 0; i < userAppsModel.count; i++) {
            const app = userAppsModel.get(i);
            apps.push([app.menuId, { iconName: app.iconName }]);
        }
        cfg_appList = JSON.stringify(apps);
    }
}
