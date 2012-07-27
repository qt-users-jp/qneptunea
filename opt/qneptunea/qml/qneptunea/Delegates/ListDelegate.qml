import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: root
    width: 400
    height: container.height
    property int height2: container.height

    property variant list

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: statusArea.height + 12

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: constants.separatorHeight
            color: constants.separatorNormalColor
            opacity: constants.separatorOpacity
        }

        Column {
            id: statusArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.leftMargin: constants.listViewMargins
            spacing: constants.listViewMargins

            Text {
                text: list.full_name + ' (' + list.member_count +')'
                width: parent.width
                font.bold: true
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSmall
                color: constants.nameColor

                Image {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    visible: list.mode == 'private'
                    source: 'image://theme/icon-m-common-locked'.concat(theme.inverted ? "-inverse" : "")
                }
            }

            Text {
                text: list.description
                width: parent.width
                wrapMode: Text.Wrap
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSmall
                color: constants.textColor
            }
        }
    }
}
