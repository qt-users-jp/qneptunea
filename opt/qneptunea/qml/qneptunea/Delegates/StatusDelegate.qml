import QtQuick 1.1
import Qt.labs.shaders 1.0
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height

    property variant item
    property variant user

    property bool __retweeted: item !== undefined && item.retweeted_status !== undefined && item.retweeted_status.user !== undefined
    property variant __item: __retweeted ? item.retweeted_status : item

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
                    when: user.id_str === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorFromMeColor
                    }
                },
                State {
                    name: "mention"
                    when: __item.text.indexOf('@' + oauth.screen_name) > -1
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
                source: __item && __item.user.screen_name ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(__item.user.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
                _id: __item && __item.user.profile_image_url ? __item.user.profile_image_url : ''
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.debug(__item.user.id_str)
                    root.linkActivated('user://'.concat(__item.user.id_str))
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
                    text: __item && __item.user && __item.user.name ? __item.user.name : ''
                    textFormat: Text.PlainText
                    font.bold: true
                    font.pixelSize: constants.fontSmall
                    font.family: constants.fontFamily
                    color: constants.nameColor
                }
                Text {
                    text: __item && __item.user && __item.user.screen_name ? '@' + __item.user.screen_name : ''
                    font.pixelSize: constants.fontSmall
                    font.family: constants.fontFamily
                    color: constants.nameColor
                }
            }

            Text {
                id: text
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                text: __item ? __item.plain_text : ''
                color: constants.contentColor
                font.pixelSize: constants.fontDefault
                font.family: constants.fontFamily
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.2

                Component.onCompleted: {
                    if (typeof root.__item !== 'undefined' && typeof root.__item.place !== 'undefined' && typeof root.__item.place.full_name !== 'undefined') {
                        var component = Qt.createComponent("Place.qml");
                        if (component.status == Component.Ready) {
                            component.createObject(statusArea, {'place': root.__item.place});
                        }
                    }

                    if (root.__retweeted) {
                        var component = Qt.createComponent("RetweetedBy.qml");
                        if (component.status == Component.Ready) {
                            component.createObject(statusArea, {'user': root.user});
                        }
                    }
                }
            }
        }
    }
}
