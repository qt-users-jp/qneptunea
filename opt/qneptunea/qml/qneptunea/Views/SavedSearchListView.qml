import QtQuick 1.1
import "../Delegates"

AbstractListView {
    id: root
    width: 400
    height: 700

    delegate: SavedSearchDelegate {
        id: delegate
        width: ListView.view.width
        search: model
        onClicked: root.showDetail(search)

        ListView.onAdd: SequentialAnimation {
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "height"; value: 0 }
            NumberAnimation { target: delegate; property: "height"; to: delegate.height2; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "clip"; value: false }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: delegate; property: "height"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: delegate; property: "clip"; value: false }
        }
    }
}
