import qs.config

import QtQuick as QQ

QQ.Text {
    id: root

    property string role: "bodyMedium"
    readonly property var _style: {
        const style = Typography[root.role];
        return style?.size === undefined ? Typography.bodyMedium : style;
    }

    color: Theme.onSurface
    textFormat: QQ.Text.PlainText
    elide: QQ.Text.ElideRight
    font.family: Typography.family
    font.pixelSize: _style.size
    font.weight: _style.weight
    lineHeightMode: QQ.Text.FixedHeight
    lineHeight: _style.lineHeight
}
