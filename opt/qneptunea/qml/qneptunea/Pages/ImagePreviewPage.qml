import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Preview')
    busy: preview.status != Image.Ready

    property string type
    property alias url: preview.source

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentWidth: 500
        contentHeight: 500
        clip: true

        PinchArea {
            width: Math.max(container.contentWidth, container.width)
            height: Math.max(container.contentHeight, container.height)

            property real initialWidth
            property real initialHeight
            onPinchStarted: {
                initialWidth = container.contentWidth
                initialHeight = container.contentHeight
            }

            onPinchUpdated: {
                // adjust content pos due to drag
                container.contentX += pinch.previousCenter.x - pinch.center.x
                container.contentY += pinch.previousCenter.y - pinch.center.y

                // resize content
                container.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
            }

            onPinchFinished: {
                // Move its content within bounds.
                container.returnToBounds()
            }

            Item {
                width: container.contentWidth
                height: container.contentHeight

                AnimatedImage {
                    id: preview
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    anchors.fill: parent
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            container.contentWidth = 500
                            container.contentHeight = 500
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: container
    }

    ProgressBar {
        id: progress
        anchors.centerIn: container
        width: container.width / 2
        minimumValue: 0
        maximumValue: 100
        value: preview.progress * 100
        Behavior on value { SmoothedAnimation { velocity: 50 } }
        visible: preview.status == Image.Loading
        indeterminate: true

        states: [
            State {
                name: "loading"
                when: progress.value > 0
                PropertyChanges {
                    target: progress
                    indeterminate: false
                }
            }
        ]
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
