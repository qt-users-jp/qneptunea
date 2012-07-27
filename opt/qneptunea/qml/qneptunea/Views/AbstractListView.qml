import QtQuick 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

ListView {
    id: root
    width: 400
    height: 700

    flickableDirection: Flickable.VerticalFlick
    flickDeceleration: 1200
    maximumFlickVelocity: 7600
    clip: true

    property bool loading: false
    signal showDetail(variant detail)
    signal linkActivated(string link)

    property bool __wasAtYBeginning: false
    property int __scrollStartedAt: 0

    onMovementStarted: {
        __wasAtYBeginning = atYBeginning
        __scrollStartedAt = contentY
        __toBeMore = false
        __toBeReload = false
    }
    onMovementEnded: {
        if (__toBeReload && test.online) {
            reload()
        }
        if (__toBeMore && test.online) {
            more()
        }
        __toBeMore = false
        __toBeReload = false
    }

    property bool __toBeReload: false
    property bool __toBeMore: false
    signal reload()
    signal more()

    header: Item {
        id: header
        width: ListView.view.width
        height: 0
        states: [
            State {
                name: "refresh"
                when: header.ListView.view.__wasAtYBeginning && header.ListView.view.__scrollStartedAt - header.ListView.view.contentY > 100
                StateChangeScript {
                    script: header.ListView.view.__toBeReload = true
                }
            }
        ]
    }

    footer: Item {
        id: footer
        width: parent.width
        height: Math.max(constants.fontDefault, more.height) * 2
        clip: true
        opacity: root.loading ? 1.0 : 0.0
        Row {
            anchors.centerIn: parent
            spacing: 10

            BusyIndicator {
                id: more
                running: false
            }

            Label {
                text: qsTr('Loading...')
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
            }

            states: [
                State {
                    name: "refresh"
                    when: footer.ListView.view.atYEnd/* && footer.ListView.view.__scrollStartedAt - footer.ListView.view.contentY < 100*/
                    PropertyChanges {
                        target: more
                        running: true
                    }
                    StateChangeScript {
                        script: footer.ListView.view.__toBeMore = true
                    }
                }
            ]
        }
    }

    property int topItemIndex: Math.min(root.indexAt(0, root.contentY + 5) + 1, root.count) - 1

    onCountChanged: timer.changed = true
    onContentYChanged: timer.changed = true

    Timer {
        id: timer
        property bool changed: false
        interval: 100
        running: timer.changed
        repeat: false
        onTriggered: {
            root.topItemIndex = Math.min(root.indexAt(0, root.contentY + 5) + 1, root.count) - 1
            timer.changed = false
        }
    }

    ScrollBar {
        anchors.top: parent.top
        anchors.right: parent.right
        height: root.height * topItemIndex / 100

        Behavior on height {
            SmoothedAnimation { velocity: 50 }
        }
    }

//    Rectangle {
//        anchors.right: scrollBar.left
//        width: 75
//        height: 100
//        Column {
//            Text { text: topItemIndex }
//            Text { text: scrollBar.height }
//            Text { text: root.count }
//            Text { text: root.model.size }
//            Text { text: root.height }
//        }
//    }
}
