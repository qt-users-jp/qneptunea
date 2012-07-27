import QtQuick 1.1

MouseArea {
    id: root
    width: 240
    height: 240
    property alias icon: image.source
    property bool fill: false

    Image {
        id: image
        anchors.centerIn: parent

        states: [
            State {
                name: 'fill'
                when: root.fill
                PropertyChanges {
                    target: image
                    width: root.width
                    height: root.height
                    smooth: true
                    clip: true
                    fillMode: Image.PreserveAspectCrop
                }
            }
        ]
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        color: 'transparent'
        border.color: constants.textColor
        border.width: 2

    }
}
