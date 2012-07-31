import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'
import '../Utils/TweetCounter.js' as TweetCounter

AbstractPage {
    id: root

    title: qsTr('Direct Message')
    busy: directMessage.loading

    property bool skipAfterTweeting: true

    DirectMessage {
        id: directMessage
        onIdStrChanged: {
            if (id_str.length > 0 && root.status === PageStatus.Active) {
                var found = pageStack.find( function(page) {
                                               return !(typeof page.skipAfterTweeting === 'boolean' && page.skipAfterTweeting)
                                           })
                if (found) {
//                    console.debug(found)
                    pageStack.pop(found)
                } else {
//                    console.debug('not found')
                    pageStack.pop()
                }
            }
        }
    }

    property bool modified: false
    property string statusText
    property variant in_reply_to
    property variant recipient

    onStatusChanged: {
        if (root.status === PageStatus.Active) {
            textArea.forceActiveFocus()
        }
    }

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        clip: true
        contentHeight: contents.height

        Column {
            id: contents
            width: parent.width
            spacing: constants.listViewMargins

            DirectMessageDelegate {
                id: in_reply_to
                width: parent.width
                visible: false
                states: [
                    State {
                        when: typeof root.in_reply_to !== 'undefined'
                        PropertyChanges {
                            target: in_reply_to
                            direct_message: root.in_reply_to
                            sender: root.in_reply_to.sender
                            recipient: root.in_reply_to.recipient
                            visible: typeof root.in_reply_to !== 'undefined'
                        }
                    }
                ]
            }

            Item {
                width: parent.width
                height: detailArea.height + 12

                ProfileImage {
                    id: icon
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    source: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(root.retweet ? root.in_reply_to.user.screen_name : verifyCredentials.screen_name).concat('&size=').concat(constants.listViewIconSizeName)
                    _id: root.retweet ? root.in_reply_to.user.profile_image_url : verifyCredentials.profile_image_url
                    width: constants.listViewIconSize
                    height: width
                }

                CountBubble {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6 + constants.listViewIconSize / 2
                    anchors.horizontalCenter: icon.horizontalCenter
                    anchors.horizontalCenterOffset: constants.listViewMargins / 2
                    value: textArea.counter
                    largeSized: true
                }

                Column {
                    id: detailArea
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: icon.right
                    anchors.leftMargin: constants.listViewMargins
                    anchors.right: parent.right
                    spacing: constants.listViewMargins

                    Row {
                        id: nameArea
                        spacing: constants.listViewMargins
                        Text {
                            text: verifyCredentials.name
                            font.bold: true
                            font.family: constants.fontFamily
                            font.pixelSize: constants.fontSmall
                            color: constants.nameColor
                        }
                        Text {
                            text: '@' + oauth.screen_name
                            font.family: constants.fontFamily
                            font.pixelSize: constants.fontSmall
                            color: constants.nameColor
                        }
                    }

                    Item {
                        width: parent.width
                        height: textArea.height
                        TextArea {
                            id: textArea
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: sendLandscape.left
                            textFormat: TextEdit.PlainText
                            wrapMode: TextEdit.WordWrap
                            enabled: !directMessage.loading
                            platformStyle: TextAreaStyle { textFont.pixelSize: constants.fontDefault }

                            property string preedit: text.substring(0, cursorPosition) + platformPreedit + text.substring(cursorPosition)
                            property int counter: TweetCounter.count(preedit, 140, configuration.short_url_length, configuration.short_url_length_https)
                        }
                        Button {
                            id: sendLandscape
                            width: visible ? 322 / 2 : 0
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            text: send.text
                            enabled: send.enabled
                            visible: !window.inPortrait
                            checked: textArea.counter >= 0
                            onClicked: send.send()
                            Behavior on width { NumberAnimation{} }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: constants.listViewMargins

                        Text {
                            text: qsTr('Send to %1').arg(root.recipient.name)
                            anchors.bottom: parent.bottom
                            font.family: constants.fontFamily
                            font.pixelSize: constants.fontSmall
                            color: constants.textColor
                        }

                        Item {
                            width: constants.listViewIconSize / 2
                            height: 1
                            anchors.bottom: parent.bottom
                            ProfileImage {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: width
                                source: root.recipient.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(root.recipient.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
                                _id: root.recipient.profile_image_url
                                smooth: true
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: constants.separatorHeight
                color: constants.separatorFromMeColor
                opacity: constants.separatorOpacity
            }
        }
    }

    ScrollDecorator { flickableItem: container }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {}
        ToolButtonRow {
            ToolButton {
                id: send

                enabled: textArea.text.length > 0
                checked: textArea.counter >= 0
                text: qsTr('Send')
                function send() {
                    var parameters = {'user_id': root.recipient.id_str, 'text': textArea.text}
                    directMessage.newDirectMessage(parameters)
                }
                onClicked: send.send()
            }
        }
    }

    StateGroup {
        states: [
            State {
                name: "hidden"
                when: sendLandscape.visible && textArea.activeFocus
                PropertyChanges {
                    target: root
                    footerOpacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { properties: 'opacity, height' }
            }
        ]
    }
}
