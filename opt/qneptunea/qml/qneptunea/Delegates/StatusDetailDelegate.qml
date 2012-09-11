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
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height

    property bool temporary: false
    property variant item
    property variant user

    property bool retweeted: defined(item.retweeted_status) && defined(item.retweeted_status.user)
    property variant __item: retweeted ? item.retweeted_status : item
    property bool __favorited: __item.favorited

    signal userClicked(variant user)
    signal linkActivated(string link)

    property alias translated: translated.text

    Item {
        id: container
        anchors.left: parent.left
        anchors.leftMargin: constants.listViewScrollbarWidth
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        height: detailArea.y + detailArea.height + 12
        clip: true

        Separator {
            id: line
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            states: [
                State {
                    name: "my tweet"
                    when: root.user.id_str === oauth.user_id
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

        MouseArea {
            id: userArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(iconArea.height, nameArea.height) + 12
            ProfileImage {
                id: iconArea
                anchors.left: parent.left
                anchors.leftMargin: constants.iconLeftMargin
                anchors.top: parent.top
                anchors.topMargin: 5
                width: 73
                height: width

                source: root.temporary ? '' : (__item.user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=bigger'.arg(__item.user.screen_name) : '')
                _id: root.temporary ? '' : to_s(__item.user.profile_image_url)
            }

            Column {
                id: nameArea
                anchors.left: iconArea.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: constants.listViewMargins

                Text {
                    text: defined(__item.user) ? to_s(__item.user.name) : ''
                    textFormat: Text.PlainText
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Text {
                    text: defined(__item.user) ? to_s(__item.user.screen_name, '@%1') : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    color: constants.nameColor
                }
            }

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-common-drilldown-arrow'.concat(theme.inverted ? "-inverse" : "")
            }

            onClicked: root.userClicked(__item.user)
        }

        Column {
            id: detailArea
            anchors.top: userArea.bottom
//            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: constants.listViewMargins

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: '<style type="text/css">a.link{%1} a.screen_name{%2} a.hash_tag{%3} a.media{%4}</style>%5'.arg(constants.linkStyle).arg(constants.screenNameStyle).arg(constants.hashTagStyle).arg(constants.mediaStyle).arg(__item.rich_text)
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontLarge * 1.40
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                onLinkActivated: root.linkActivated(link)
                opacity: translated.text.length > 0 ? 0.75 : 1.0
            }
            Text {
                id: translated
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                visible: translated.text.length > 0
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontLarge * 1.40
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                onLinkActivated: root.linkActivated(link)
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: root.translated = ''
                }
            }

            Row {
                anchors.left: parent.left
                spacing: constants.listViewMargins

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: __item.created_at ? Qt.formatDateTime(new Date(__item.created_at), constants.dateTimeFormat) : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    property variant contributors: __item.contributors && __item.contributors.length > 0 ? __item.contributors[0] : undefined
                    text: qsTr('by <a style="%2" href="user://%1">%1</a>').arg(contributors).arg(constants.screenNameStyle)
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                    visible: contributors !== undefined
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('<style type="text/css">a{%2}</style>via %1').arg(__item.source).arg(constants.sourceStyle)
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                    onLinkActivated: root.linkActivated(link)
                }
            }

        }
    }
    Component.onCompleted: addRetweeted()
    onRetweetedChanged: addRetweeted()
    function addRetweeted() {
        if (root.retweeted && typeof root.user !== 'undefined') {
            var component = Qt.createComponent("RetweetedBy.qml");
            if (component.status == Component.Ready) {
                component.createObject(detailArea, {'user': root.user});
            }
        }
    }
}
