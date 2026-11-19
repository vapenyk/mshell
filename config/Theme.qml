pragma Singleton

import "Theme.model.js" as Model

import Quickshell
import Quickshell.Io

import QtQml
import QtQuick

Singleton {
    id: root

    readonly property var _accents: JSON.parse(paletteFile.text())
    readonly property var _scheme: Model.pickScheme(_accents, Config.accent)

    readonly property color primary: _scheme.primary
    readonly property alias onPrimary: contentColors.primary
    readonly property color primaryContainer: _scheme.primaryContainer
    readonly property alias onPrimaryContainer: contentColors.primaryContainer
    readonly property color secondary: _scheme.secondary
    readonly property alias onSecondary: contentColors.secondary
    readonly property color secondaryContainer: _scheme.secondaryContainer
    readonly property alias onSecondaryContainer: contentColors.secondaryContainer
    readonly property color tertiary: _scheme.tertiary
    readonly property alias onTertiary: contentColors.tertiary
    readonly property color tertiaryContainer: _scheme.tertiaryContainer
    readonly property alias onTertiaryContainer: contentColors.tertiaryContainer
    readonly property color error: _scheme.error
    readonly property alias onError: contentColors.error
    readonly property color errorContainer: _scheme.errorContainer
    readonly property alias onErrorContainer: contentColors.errorContainer
    readonly property color background: _scheme.background
    readonly property alias onBackground: contentColors.background
    readonly property color surface: _scheme.surface
    readonly property alias onSurface: contentColors.surface
    readonly property color surfaceVariant: _scheme.surfaceVariant
    readonly property alias onSurfaceVariant: contentColors.surfaceVariant
    readonly property color surfaceDim: _scheme.surfaceDim
    readonly property color surfaceBright: _scheme.surfaceBright
    readonly property color surfaceContainerLowest: _scheme.surfaceContainerLowest
    readonly property color surfaceContainerLow: _scheme.surfaceContainerLow
    readonly property color surfaceContainer: _scheme.surfaceContainer
    readonly property color surfaceContainerHigh: _scheme.surfaceContainerHigh
    readonly property color surfaceContainerHighest: _scheme.surfaceContainerHighest
    readonly property color outline: _scheme.outline
    readonly property color outlineVariant: _scheme.outlineVariant
    readonly property color inverseSurface: _scheme.inverseSurface
    readonly property color inverseOnSurface: _scheme.inverseOnSurface
    readonly property color inversePrimary: _scheme.inversePrimary
    readonly property color shadow: _scheme.shadow
    readonly property color scrim: _scheme.scrim
    readonly property real dialogScrimOpacity: 0.32
    readonly property color surfaceTint: _scheme.surfaceTint
    readonly property color transparent: "transparent"

    readonly property real stateHover: 0.08
    readonly property real stateFocus: 0.10
    readonly property real statePressed: 0.10
    readonly property real stateDragged: 0.16
    readonly property real disabledContentOpacity: 0.38
    readonly property real disabledContainerOpacity: 0.12
    readonly property var popupShadow: ({ opacity: 0.24, blur: 24, offsetY: 8 })

    function sizeClass(screen: ShellScreen): string {
        return Model.sizeClass(screen?.width ?? 0);
    }

    // QML treats direct bindings whose names start with on and a capital as signal handlers.
    QtObject {
        id: contentColors

        readonly property color primary: root._scheme.onPrimary
        readonly property color primaryContainer: root._scheme.onPrimaryContainer
        readonly property color secondary: root._scheme.onSecondary
        readonly property color secondaryContainer: root._scheme.onSecondaryContainer
        readonly property color tertiary: root._scheme.onTertiary
        readonly property color tertiaryContainer: root._scheme.onTertiaryContainer
        readonly property color error: root._scheme.onError
        readonly property color errorContainer: root._scheme.onErrorContainer
        readonly property color background: root._scheme.onBackground
        readonly property color surface: root._scheme.onSurface
        readonly property color surfaceVariant: root._scheme.onSurfaceVariant
    }

    FileView {
        id: paletteFile

        path: Quickshell.shellPath("config/accents.json")
        blockLoading: true
    }
}
