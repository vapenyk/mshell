pragma Singleton

import Quickshell

Singleton {
    readonly property int short1: 50
    readonly property int short2: 100
    readonly property int short3: 150
    readonly property int short4: 200
    readonly property int medium1: 250
    readonly property int medium2: 300
    readonly property int medium3: 350
    readonly property int medium4: 400
    readonly property int long1: 450
    readonly property int long2: 500

    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var standardDecelerate: [0, 0, 0, 1, 1, 1]
    readonly property var standardAccelerate: [0.3, 0, 1, 1, 1, 1]
    readonly property var emphasized: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var emphasizedAccelerate: [0.3, 0, 0.8, 0.15, 1, 1]

    // Initial SpringAnimation presets. Step 09 tunes them against the motion references.
    readonly property var spatialFast: ({ spring: 4.0, damping: 0.35, mass: 1 })
    readonly property var spatialDefault: ({ spring: 2.7, damping: 0.30, mass: 1 })
    readonly property var spatialSlow: ({ spring: 1.5, damping: 0.25, mass: 1 })
    readonly property var effectsFast: ({ spring: 5.0, damping: 0.50, mass: 1 })
    readonly property var effectsDefault: ({ spring: 3.5, damping: 0.45, mass: 1 })
    readonly property var effectsSlow: ({ spring: 2.2, damping: 0.40, mass: 1 })

    readonly property real enterScale: 0.92
    readonly property int notificationTimeout: 5000
    readonly property int osdTimeout: 1500
    readonly property int popupSlideDistance: 8
    readonly property int sharedAxisDistance: 30
    readonly property real sharedAxisFadeOutFraction: 0.35
    readonly property real containerTransformFadeOutFraction: 0.30
    readonly property int fadeThroughOutDuration: 90
    readonly property int fadeThroughInDuration: 210
}
