/* Copyright (c) 2012-2013 QNeptunea Project.
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
        anchors.leftMargin: constants.listViewScrollbarWidth
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
            ProfileImage {
                id: iconArea
                anchors.left: parent.left
                anchors.leftMargin: constants.iconLeftMargin
                anchors.top: parent.top
                anchors.topMargin: 5
                width: 73
                height: width

                source: sender.profile_image_url ? to_s(sender.profile_image_url).replace('_normal', '_bigger') : ''
                _id: iconArea.source
            }

            Column {
                id: nameArea
                anchors.left: iconArea.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: constants.listViewMargins

                Text {
                    text: sender ? to_s(sender.name) : ''
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Text {
                    text: sender ? to_s(sender.screen_name, '@%1') : ''
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
                text: '<style type="text/css">a.link{%1} a.screen_name{%2} a.hash_tag{%3} a.media{%4}</style>%5'.arg(constants.linkStyle).arg(constants.screenNameStyle).arg(constants.hashTagStyle).arg(constants.mediaStyle).arg(item.rich_text)
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
                    text: item.created_at ? Qt.formatDateTime(new Date(item.created_at), constants.dateTimeFormat) : ''
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
                    text: qsTr('Sent to %1').arg(to_s(recipient.name))
                    anchors.bottom: parent.bottom
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: - parent.height / 3
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
                        source: recipient.profile_image_url ? to_s(recipient.profile_image_url).replace('_normal', '_%1').arg(constants.listViewIconSizeName) : ''
                        _id: source
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
