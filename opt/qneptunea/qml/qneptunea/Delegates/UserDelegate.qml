import QtQuick 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height
    property int height2: container.height

    property variant user

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: Math.max(iconArea.height, statusArea.height) + 12

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: constants.separatorHeight
            color: constants.separatorNormalColor
            opacity: constants.separatorOpacity
        }

        Item {
            id: iconArea
            anchors.left: parent.left
            anchors.leftMargin: constants.iconLeftMargin
            anchors.top: parent.top
            anchors.topMargin: 5
            width: constants.listViewIconSize
            height: width

            ProfileImage {
                id: icon
                anchors.fill: parent
                source: user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
                _id: user.profile_image_url ? user.profile_image_url : ''

                Image {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -10
                    opacity: user.protected ? 0.75 : 0.0
                    source: 'image://theme/icon-m-common-locked'.concat(theme.inverted ? "-inverse" : "")
                }
            }
        }

        Column {
            id: statusArea
            anchors.left: iconArea.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.leftMargin: constants.listViewMargins

            Row {
                spacing: constants.listViewMargins
                Text {
                    id: user_name
                    text: user.name
                    textFormat: Text.PlainText
                    color: constants.nameColor
                    font.pixelSize: constants.fontSmall
                    font.family: constants.fontFamily
                    font.bold: true
                }
                Text {
                    id: user_screen_name
                    text: '@' + user.screen_name
                    color: constants.nameColor
                    font.pixelSize: constants.fontSmall
                    font.family: constants.fontFamily
                }
            }

            Text {
                id: text
                text: user.description ? user.description.replace(/\r\n/g, "\n").replace(/\r/g, "\n") : ''
                textFormat: Text.PlainText
                color: constants.contentColor
                font.pixelSize: constants.fontDefault
                font.family: constants.fontFamily
                width: parent.width
                wrapMode: Text.Wrap
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.2
            }
        }
    }
}
