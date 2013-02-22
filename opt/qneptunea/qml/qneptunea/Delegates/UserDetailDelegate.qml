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
import Twitter4QML 1.1
import '../QNeptunea/Components/'

Item {
    id: root
    width: 400
    height: container.height

    property variant user
    property bool followsYou: false

    signal avatarClicked(variant user)
    signal userClicked(variant user)
    signal linkActivated(string link)

    property StateGroup __pluginItem

    Item {
        id: container
        anchors.left: parent.left
        anchors.leftMargin: constants.listViewScrollbarWidth
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        height: detailArea.y + detailArea.height + 10 + 2

        Item {
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

                source: user.profile_image_url ? to_s(root.user.profile_image_url).replace('_normal', '_%1').arg(constants.listViewIconSizeName) : ''
                _id: iconArea.source

                Image {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -10
                    opacity: user.protected ? 0.75 : 0.0
                    source: 'image://theme/icon-m-common-locked'.concat(theme.inverted ? "-inverse" : "")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.avatarClicked(root.user)
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
                    text: to_s(user.name)
                    textFormat: Text.PlainText
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Row {
                    spacing: constants.fontDefault
                    Text {
                        text: to_s(user.screen_name, '@%1')
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.nameColor
                    }
                    Text {
                        text: qsTr('FOLLOWS YOU')
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.textColor
                        visible: root.followsYou
                    }
                }
            }
        }

        Column {
            id: detailArea
            anchors.top: userArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: constants.listViewMargins

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: user.description.replace(/\r/g, '')
                textFormat: Text.PlainText
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.40
            }

            Text {
                width: parent.width
                text: '<a style="%1" href="%2">%3</a>'.arg(constants.placeStyle).arg(user.location).arg(user.location)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSmall
                color: constants.textColor
            }
            Text {
                width: parent.width
                text: '<a style="%1" href="%2">%2</a>'.arg(constants.linkStyle).arg(user.url)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (user.url.length > 0) root.linkActivated(user.url)
                }
            }
        }
    }
}
