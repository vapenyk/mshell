pragma Singleton

import Quickshell

import QtQuick

Singleton {
    readonly property list<string> _families: Qt.fontFamilies()
    readonly property string family: _families.includes("Roboto Flex") ? "Roboto Flex"
                                   : _families.includes("Roboto") ? "Roboto" : "sans-serif"
    readonly property string iconFamily: "Material Symbols Rounded"

    readonly property var displayLarge: ({ size: 57, lineHeight: 64, weight: 400 })
    readonly property var displayMedium: ({ size: 45, lineHeight: 52, weight: 400 })
    readonly property var displaySmall: ({ size: 36, lineHeight: 44, weight: 400 })
    readonly property var headlineLarge: ({ size: 32, lineHeight: 40, weight: 400 })
    readonly property var headlineMedium: ({ size: 28, lineHeight: 36, weight: 400 })
    readonly property var headlineSmall: ({ size: 24, lineHeight: 32, weight: 400 })
    readonly property var titleLarge: ({ size: 22, lineHeight: 28, weight: 400 })
    readonly property var titleMedium: ({ size: 16, lineHeight: 24, weight: 500 })
    readonly property var titleSmall: ({ size: 14, lineHeight: 20, weight: 500 })
    readonly property var bodyLarge: ({ size: 16, lineHeight: 24, weight: 400 })
    readonly property var bodyMedium: ({ size: 14, lineHeight: 20, weight: 400 })
    readonly property var bodySmall: ({ size: 12, lineHeight: 16, weight: 400 })
    readonly property var labelLarge: ({ size: 14, lineHeight: 20, weight: 500 })
    readonly property var labelMedium: ({ size: 12, lineHeight: 16, weight: 500 })
    readonly property var labelSmall: ({ size: 11, lineHeight: 16, weight: 500 })
    readonly property var clockHuge: ({ size: 120, lineHeight: 112, weight: 500 })
}
