import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height

    property variant direct_message
    property variant sender
    property variant recipient

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
                    when: sender.id_str === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorFromMeColor
                    }
                },
                State {
                    when: recipient.id_str === oauth.user_id
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
            anchors.leftMargin: constants.iconLeftMargin
            anchors.top: parent.top
            anchors.topMargin: 5
            width: constants.listViewIconSize
            height: width

            ProfileImage {
                id: icon
                anchors.fill: parent
                source: sender.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(sender.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
                _id: sender.profile_image_url ? sender.profile_image_url : ''
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.linkActivated('user://'.concat(sender.id_str))
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
                    text: sender.name ? sender.name : ''
                    color: constants.nameColor
                    font.pixelSize: constants.fontSmall
                    font.family: constants.fontFamily
                    font.bold: true
                }
                Text {
                    text: sender.screen_name ? '@' + sender.screen_name : ''
                    color: constants.nameColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                }
            }

            Text {
                id: text
                text: direct_message.plain_text
                color: constants.contentColor
                font.pixelSize: constants.fontDefault
                font.family: constants.fontFamily
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.2
            }

            Row {
                anchors.right: parent.right
                visible: sender.id_str === oauth.user_id
                spacing: constants.listViewMargins

                Text {
                    text: qsTr('Sent to %1').arg(recipient.name ? recipient.name : '')
                    anchors.bottom: parent.bottom
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                }

                Item {
                    width: constants.listViewIconSize / 2
                    height: 1
                    anchors.bottom: parent.bottom
                    ProfileImage {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: width
                        source: recipient.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(recipient.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
                        _id: recipient.profile_image_url ? recipient.profile_image_url : ''
                        smooth: true
                    }
                }
            }
        }
    }
}
