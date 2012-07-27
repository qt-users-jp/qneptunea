import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import Twitter4QML.extra 1.0
import '../QNeptunea/Components/'
import '../Views'

Page {
    id: root

    property alias title: header.text
    property alias busy: header.busy
    property AbstractListView view
    property variant model
    property Component delegate

    TitleBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        onClicked: root.view.positionViewAtBeginning()

        states: [
            State {
                name: "show time"
                when: root.view.moving && __topData.created_at
                PropertyChanges {
                    target: header
                    text: Qt.formatDateTime(new Date(__topData.created_at), 'M/d hh:mm')
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    Item {
        id: container
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
    }
    onViewChanged: view.parent = container
}
