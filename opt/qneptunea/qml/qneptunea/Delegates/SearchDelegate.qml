import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height
    property int height2: container.height

    property variant search
    property variant metadata

    signal linkActivated(string link)

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: Math.max(iconArea.height, statusArea.height) + 12

        Rectangle {
            id: line
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: constants.separatorHeight
            color: constants.separatorNormalColor
            opacity: constants.separatorOpacity

            states: [
                State {
                    name: "my tweet"
                    when: search.from_user_id === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorFromMeColor
                    }
                },
                State {
                    name: "mention"
                    when: search.text.indexOf('@' + oauth.screen_name) > -1
                    PropertyChanges {
                        target: line
                        color: constants.separatorToMeColor
                    }
                }
            ]
        }

        Item {
            id: iconArea
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 5
            width: constants.listViewIconSize
            height: width

            ProfileImage {
                id: icon
                anchors.fill: parent
                anchors.margins: 2
                source: search.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(search.from_user).concat('&size=').concat(constants.listViewIconSizeName) : ''
                _id: search.profile_image_url ? search.profile_image_url : ''
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.linkActivated('user://'.concat(search.from_user_id_str))
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
                    text: search.from_user_name ? search.from_user_name : ''
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.nameColor
                }
                Text {
                    text: search.from_user ? '@' + search.from_user : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.nameColor
                }
            }

            Text {
                id: text
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: search.plain_text
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.contentColor
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.2
            }
        }
    }
}
