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
    property int height2: container.height

    property variant user

    Item {
        id: container
        anchors.left: parent.left
        anchors.leftMargin: constants.listViewScrollbarWidth
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: Math.max(iconArea.height, statusArea.height) + 12

        Separator {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
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
                source: user.profile_image_url ? to_s(root.user.profile_image_url).replace('_normal', '_%1').arg(constants.listViewIconSizeName) : ''
                _id: icon.source

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
                    text: '@%1'.arg(user.screen_name)
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
