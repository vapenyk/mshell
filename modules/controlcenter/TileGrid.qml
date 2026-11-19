pragma ComponentBehavior: Bound

import qs.config
import "tiles"
import "TileGrid.model.js" as Model

import Quickshell
import QtQuick

Item {
    id: root

    readonly property var _order: Model.visibleTiles(Config.tiles, registry.definitions)
    readonly property int _columns: Model.columnsFor(width + 2 * Sizing.popupInnerPadding)
    readonly property int _cellWidth: Math.max(0, Math.floor((width - (_columns - 1) * slots.spacing) / _columns))

    implicitHeight: slots.implicitHeight

    TileRegistry {
        id: registry
    }

    // Flow positions fixed slots. The keyed delegates follow their model index
    // because a Repeater model move does not reorder Flow's child items.
    Flow {
        id: slots

        width: root.width
        spacing: Sizing.tileGridGap

        Repeater {
            id: slotRepeater

            model: root._order.length

            delegate: Item {
                required property int index

                width: Model.spanWidth(registry.definitions[root._order[index]]?.span ?? 1, root._columns, root._cellWidth, slots.spacing)
                height: Sizing.tileHeight
            }
        }
    }

    Repeater {
        model: ScriptModel {
            values: root._order
        }

        delegate: Loader {
            required property string modelData
            readonly property int _slotIndex: root._order.indexOf(modelData)
            readonly property Item slot: _slotIndex >= 0 && _slotIndex < slotRepeater.count ? slotRepeater.itemAt(_slotIndex) : null

            x: slot?.x ?? 0
            y: slot?.y ?? 0
            width: slot?.width ?? 0
            height: Sizing.tileHeight
            sourceComponent: registry.definitions[modelData].comp

            Behavior on x {
                SpringAnimation {
                    spring: Motion.spatialFast.spring
                    damping: Motion.spatialFast.damping
                    mass: Motion.spatialFast.mass
                }
            }

            Behavior on y {
                SpringAnimation {
                    spring: Motion.spatialFast.spring
                    damping: Motion.spatialFast.damping
                    mass: Motion.spatialFast.mass
                }
            }
        }
    }
}
