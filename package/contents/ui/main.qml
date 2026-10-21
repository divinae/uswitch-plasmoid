/*
 *  SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *  SPDX-FileCopyrightText: 2026 Jakub Lipiński <lipinski.j@pm.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.coreaddons as KCoreAddons
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.sessions as Sessions

import com.dv.uswitcher.private as USwitcher

PlasmoidItem {
    id: root

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property bool showFace: Plasmoid.configuration.showFace
    readonly property bool showSett: Plasmoid.configuration.showSett
    readonly property bool showName: Plasmoid.configuration.showName
    readonly property bool showFullName: Plasmoid.configuration.showFullName
    // TTY number and X display
    readonly property bool showTechnicalInfo: Plasmoid.configuration.showTechnicalInfo
    readonly property bool iconPositionRight: Plasmoid.configuration.iconPositionRight
    readonly property string iconName: Plasmoid.configuration.icon || "avatar-default-symbolic"

    readonly property string displayedName: showFullName && kuser.fullName ? kuser.fullName : kuser.loginName
    readonly property string avatarIcon: kuser.faceIconUrl.toString()

    readonly property string userSwitcherDomain: "plasma_applet_org.kde.plasma.userswitcher"
    readonly property string lookAndFeelDomain: "plasma_lookandfeel_org.kde.lookandfeel"

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 12

    toolTipTextFormat: Text.StyledText
    toolTipSubText: i18nd(userSwitcherDomain, "You are logged in as <b>%1</b>", displayedName)

    // revert to the plasmoid icon if no face given
    Plasmoid.icon: avatarIcon || Plasmoid.metaData.iconName

    KCoreAddons.KUser {
        id: kuser
    }

    USwitcher.AppsModel {
        id: appsModel
        appList: Plasmoid.configuration.appList
    }

    compactRepresentation: MouseArea {
        id: compactRoot

        // Taken from DigitalClock to ensure uniform sizing when next to each other
        readonly property bool tooSmall: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
            && Math.round(2 * (compactRoot.height / 5)) <= Kirigami.Theme.smallFont.pixelSize
        readonly property real iconSize: root.isVertical ? compactRoot.width : compactRoot.height

        Layout.minimumWidth: root.isVertical ? 0 : compactRow.implicitWidth
        Layout.maximumWidth: root.isVertical ? Infinity : Layout.minimumWidth
        Layout.preferredWidth: root.isVertical ? -1 : Layout.minimumWidth

        Layout.minimumHeight: root.isVertical ? compactRow.implicitHeight : Kirigami.Theme.smallFont.pixelSize
        Layout.maximumHeight: root.isVertical ? Layout.minimumHeight : Infinity
        Layout.preferredHeight: root.isVertical ? Layout.minimumHeight : Kirigami.Units.iconSizes.sizeForLabels * 2

        hoverEnabled: true

        property bool wasExpanded
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Grid {
            id: compactRow

            anchors.centerIn: parent
            rows: root.isVertical ? -1 : 1
            columns: root.isVertical ? 1 : -1
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            layoutDirection: root.iconPositionRight ? Qt.RightToLeft : Qt.LeftToRight
            spacing: Kirigami.Units.smallSpacing

            KirigamiComponents.Avatar {
                width: compactRoot.iconSize
                height: compactRoot.iconSize
                source: root.avatarIcon
                name: root.displayedName
                visible: root.showFace
            }

            Kirigami.Icon {
                width: compactRoot.iconSize
                height: compactRoot.iconSize
                source: root.iconName
                active: compactRoot.containsMouse
                visible: root.showSett
            }

            PlasmaComponents3.Label {
                width: root.isVertical ? compactRoot.width : implicitWidth
                height: root.isVertical ? implicitHeight : compactRoot.height
                text: root.displayedName
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                elide: root.isVertical ? Text.ElideRight : Text.ElideNone
                fontSizeMode: root.isVertical ? Text.FixedSize : Text.VerticalFit
                font.pixelSize: compactRoot.tooSmall || root.isVertical
                    ? Kirigami.Theme.defaultFont.pixelSize
                    : Kirigami.Units.iconSizes.roundedIconSize(Kirigami.Units.gridUnit * 2)
                minimumPointSize: Kirigami.Theme.smallFont.pointSize
                visible: root.showName
            }
        }
    }

    fullRepresentation: Item {
        id: fullRoot

        implicitHeight: column.implicitHeight
        implicitWidth: column.implicitWidth

        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: implicitHeight
        Layout.minimumWidth: Layout.preferredWidth
        Layout.minimumHeight: Layout.preferredHeight
        Layout.maximumWidth: Layout.preferredWidth
        Layout.maximumHeight: Screen.height / 2

        Sessions.SessionManagement {
            id: sm
        }

        Sessions.SessionsModel {
            id: sessionsModel
        }

        Connections {
            target: root
            function onExpandedChanged() {
                if (root.expanded) {
                    sessionsModel.reload();
                }
            }
        }

        ColumnLayout {
            id: column

            anchors.fill: parent
            spacing: 0

            Repeater {
                model: appsModel

                ActionListDelegate {
                    text: model.name
                    icon.name: model.iconName
                    visible: model.available
                    onClicked: {
                        appsModel.launch(index);
                        root.expanded = false;
                    }
                }
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
                visible: appsModel.count > 0
            }

            UserListDelegate {
                id: currentUserItem
                text: root.displayedName
                subText: i18n("Current user")
                source: root.avatarIcon
                hoverEnabled: false
            }

            PlasmaComponents3.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
                PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

                ListView {
                    id: userList
                    model: sessionsModel

                    focus: true
                    interactive: true
                    keyNavigationWraps: true

                    delegate: UserListDelegate {
                        width: ListView.view.width

                        activeFocusOnTab: true

                        text: {
                            if (!model.session) {
                                return i18nc("Nobody logged in on that session", "Unused");
                            }
                            if (model.realName && root.showFullName) {
                                return model.realName;
                            }
                            return model.name;
                        }
                        source: model.icon
                        subText: {
                            if (!root.showTechnicalInfo) {
                                return "";
                            }
                            if (model.isTty) {
                                return i18nc("User logged in on console number", "TTY %1", model.vtNumber);
                            } else if (model.displayNumber) {
                                return i18nc("User logged in on console (X display number)", "on %1 (%2)", model.vtNumber, model.displayNumber);
                            }
                            return "";
                        }

                        KeyNavigation.up: index === 0 ? currentUserItem.nextItemInFocusChain() : userList.itemAtIndex(index - 1)
                        KeyNavigation.down: index === userList.count - 1 ? newSessionButton : userList.itemAtIndex(index + 1)

                        Accessible.description: i18nc("@action:button", "Switch to User %1", text)

                        onClicked: sessionsModel.switchUser(model.vtNumber, sessionsModel.shouldLock)
                    }
                }
            }

            ActionListDelegate {
                id: newSessionButton
                text: i18ndc(root.userSwitcherDomain, "@action", "New Session")
                icon.name: "system-switch-user"
                visible: sessionsModel.canStartNewSession
                onClicked: sessionsModel.startNewSession(sessionsModel.shouldLock)
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
            }

            ActionListDelegate {
                text: i18ndc(root.userSwitcherDomain, "@action", "Lock Screen")
                icon.name: "system-lock-screen"
                visible: sm.canLock
                onClicked: sm.lock()
            }

            ActionListDelegate {
                text: i18ndc(root.lookAndFeelDomain, "Suspend to RAM", "Sleep")
                icon.name: "system-suspend"
                visible: sm.canSuspend
                onClicked: sm.suspend()
            }

            ActionListDelegate {
                text: i18ndc(root.userSwitcherDomain, "Show a dialog with options to logout/shutdown/restart", "Leave…")
                icon.name: "system-log-out"
                visible: sm.canLogout
                onClicked: sm.requestLogoutPrompt()
            }
        }
    }
}
