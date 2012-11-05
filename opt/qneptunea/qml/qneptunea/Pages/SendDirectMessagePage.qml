/* Copyright (c) 2012 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
                    pageStack.pop(found)
                } else {
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
        switch (root.status) {
        case PageStatus.Active:
            textArea.forceActiveFocus()
            break
        case PageStatus.Inactive:
            textArea.text = ''
            break
        default:
            break
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
                        when: defined(root.in_reply_to)
                        PropertyChanges {
                            target: in_reply_to
                            item: root.in_reply_to
                            visible: true
                        }
                    }
                ]
            }

            Item {
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewMargins
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewMargins
                height: detailArea.height + 12

                ProfileImage {
                    id: icon
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    source: 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=%2'.arg(verifyCredentials.screen_name).arg(constants.listViewIconSizeName)
                    _id: verifyCredentials.profile_image_url
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
                            text: '@%1'.arg(oauth.screen_name)
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
                            text: qsTr('Send to %1').arg(defined(root.recipient) ? to_s(root.recipient.name) : '')
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
                                source: defined(root.recipient) && defined(root.recipient.profile_image_url) ? 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=%2'.arg(root.recipient.screen_name).arg(constants.listViewIconSizeName) : ''
                                _id: defined(root.recipient) ? to_s(root.recipient.profile_image_url) : ''
                                smooth: true
                            }
                        }
                    }
                }
            }
            Separator {
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewMargins
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewMargins
                color: constants.separatorFromMeColor
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
