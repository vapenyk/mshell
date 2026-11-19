pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick as QQ
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

Basic.AbstractButton {
    id: row

    required property string iconName
    required property string subtitle
    property bool connected: false
    property string trailingIcon: connected ? "link_off" : "chevron_right"

    readonly property QQ.color _contentColor: connected ? Theme.onPrimary : Theme.onSurface

    implicitHeight: Sizing.tileHeight
    padding: Sizing.popupInnerPadding
    spacing: Sizing.popupGap
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    QQ.Accessible.name: connected ? qsTr("Disconnect from %1").arg(text) : qsTr("Connect to %1").arg(text)
    QQ.Accessible.description: subtitle
    QQ.Keys.onReturnPressed: row.click()
    QQ.Keys.onEnterPressed: row.click()

    background: Components.Surface {
        container: row.connected ? Theme.primary : Theme.surfaceContainerHigh
        radius: Shape.large

        Components.StateLayer {
            anchors.fill: parent
            radius: parent.radius
            contentColor: row._contentColor
            hovered: row.enabled && row.hovered
            pressed: row.down
            focused: row.visualFocus
        }
    }

    contentItem: QQL.RowLayout {
        spacing: row.spacing

        Components.Icon {
            name: row.iconName
            color: row._contentColor
        }

        QQL.ColumnLayout {
            QQL.Layout.fillWidth: true
            spacing: Shape.none

            Components.Text {
                QQL.Layout.fillWidth: true
                text: row.text
                color: row._contentColor
                role: "labelLarge"
            }

            Components.Text {
                QQL.Layout.fillWidth: true
                text: row.subtitle
                color: row.connected ? Theme.onPrimary : Theme.onSurfaceVariant
                role: "bodySmall"
            }
        }

        Components.Icon {
            name: row.trailingIcon
            size: Sizing.smallIconSize
            color: row._contentColor
        }
    }
}
