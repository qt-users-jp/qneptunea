import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height

    property variant item
    property variant sender
    property variant recipient

    signal userClicked(variant user)
    signal linkActivated(string link)

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        height: detailArea.y + detailArea.height + 12

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
                    when: sender.id_str === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorFromMeColor
                    }
                },
                State {
                    name: "mention"
                    when: recipient.id_str === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorToMeColor
                    }
                }
            ]
        }

        MouseArea {
            id: userArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(iconArea.height, nameArea.height) + constants.listViewScrollbarWidth * 2
            Item {
                id: iconArea
                anchors.left: parent.left
                anchors.leftMargin: constants.iconLeftMargin
                anchors.top: parent.top
                anchors.topMargin: 5
                width: 73
                height: width

                ProfileImage {
                    anchors.fill: parent
                    source: sender.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(sender.screen_name).concat('&size=bigger') : ''
                    _id: sender.profile_image_url ? sender.profile_image_url : ''
                }
            }

            Column {
                id: nameArea
                anchors.left: iconArea.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: constants.listViewMargins

                Text {
                    text: sender && sender.name ? sender.name : ''
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Text {
                    text: sender && sender.screen_name ? '@' + sender.screen_name : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
            }

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-common-drilldown-arrow'.concat(theme.inverted ? "-inverse" : "")
            }

            onClicked: root.userClicked(sender)
        }

        Column {
            id: detailArea
            anchors.top: userArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: constants.listViewMargins

            Text {
                id: text
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: qsTr('<style type="text/css">a.link{%2} a.screen_name{%3} a.hash_tag{%4} a.media{%5}</style>%1').arg(item.rich_text).arg(constants.linkStyle).arg(constants.screenNameStyle).arg(constants.hashTagStyle).arg(constants.mediaStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.40
                onLinkActivated: root.linkActivated(link)
            }

            Row {
                anchors.left: parent.left
                spacing: constants.listViewMargins

                Text {
                    text: item.created_at ? Qt.formatDateTime(new Date(item.created_at), 'M/d hh:mm') : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }
            }

            Row {
                anchors.right: parent.right
                visible: sender.id_str === oauth.user_id
                spacing: constants.listViewMargins

                Text {
                    text: 'Sent to'
                    anchors.bottom: parent.bottom
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                Text {
                    anchors.bottom: parent.bottom
                    text: recipient.name ? recipient.name : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.nameColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.userClicked(recipient)
                    }
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
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.userClicked(recipient)
                    }
                }
            }
        }
    }
}
