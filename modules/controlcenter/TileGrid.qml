pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "tiles"
import "TileGrid.model.js" as Model

import Quickshell
import QtQuick

Item {
    id: root

    readonly property var _order: Model.visibleTiles(Config.tiles, registry.definitions)
    readonly property int _columns: Model.columnsFor(width + 2 * Sizing.popupInnerPadding)
    readonly property int _cellWidth: Math.max(0, Math.floor((width - (_columns - 1) * slots.spacing) / _columns))

    readonly property int _slotHeight: Sizing.tileHeight + (UiState.editMode ? Sizing.pillHeight : 0)
    implicitHeight: slots.implicitHeight

    function _moveTile(from: int, to: int): void {
        if (UiState.editMode && from >= 0 && to >= 0 && to < _order.length)
            Config.setTiles(Model.reorderVisible(Config.tiles, registry.definitions, from, to));
    }

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
                height: root._slotHeight
            }
        }
    }

    Repeater {
        model: ScriptModel {
            values: root._order
        }

        delegate: Item {
            id: tileSlot

            required property string modelData
            readonly property int _slotIndex: root._order.indexOf(modelData)
            readonly property Item slot: _slotIndex >= 0 && _slotIndex < slotRepeater.count ? slotRepeater.itemAt(_slotIndex) : null

            x: slot?.x ?? 0
            y: slot?.y ?? 0
            width: slot?.width ?? 0
            height: root._slotHeight

            Loader {
                id: tile

                width: parent.width
                height: Sizing.tileHeight
                enabled: !UiState.editMode
                sourceComponent: registry.definitions[tileSlot.modelData].comp
            }

            Row {
                anchors.top: tile.bottom
                width: parent.width
                visible: UiState.editMode

                Components.IconButton {
                    width: parent.width / 2
                    height: Sizing.pillHeight
                    enabled: tileSlot._slotIndex > 0
                    iconName: "chevron_left"
                    text: qsTr("Move %1 left").arg(tile.item?.title ?? "")
                    onClicked: root._moveTile(tileSlot._slotIndex, tileSlot._slotIndex - 1)
                }

                Components.IconButton {
                    width: parent.width / 2
                    height: Sizing.pillHeight
                    enabled: tileSlot._slotIndex >= 0 && tileSlot._slotIndex < root._order.length - 1
                    iconName: "chevron_right"
                    text: qsTr("Move %1 right").arg(tile.item?.title ?? "")
                    onClicked: root._moveTile(tileSlot._slotIndex, tileSlot._slotIndex + 1)
                }
            }

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
