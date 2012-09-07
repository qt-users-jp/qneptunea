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
    width: 400
    height: container.height

    property variant user
    property alias text: text.text
    property alias separatorColor: separator.color
    default property alias content: contentArea.children

    signal linkActivated(string link)

    Item {
        id: container
        anchors.left: parent.left
        anchors.leftMargin: constants.listViewScrollbarWidth
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: Math.max(iconArea.height, contentArea.y + contentArea.height) + 10 + constants.listViewSpacing - constants.separatorHeight

        Separator {
            id: separator
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (constants.listViewSpacing - constants.separatorHeight) / 2
            anchors.left: parent.left
            anchors.right: parent.right
        }

        MouseArea {
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
                source: defined(root.user) && defined(root.user.screen_name) ? 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=%2'.arg(root.user.screen_name).arg(constants.listViewIconSizeName) : ''
                _id: defined(root.user) ? to_s(root.user.profile_image_url) : ''
            }

            onClicked: root.linkActivated('user://%1'.arg(root.user.id_str))
        }

        Text {
            id: name
            anchors.left: iconArea.right
            anchors.leftMargin: constants.listViewMargins
            anchors.top: parent.top
            anchors.topMargin: 5
            text: defined(root.user) ? to_s(root.user.name) : ''
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: constants.fontSmall
            font.family: constants.fontFamily
            color: constants.nameColor
        }

        Text {
            anchors.left: name.right
            anchors.leftMargin: constants.listViewMargins
            anchors.right: parent.right
            anchors.verticalCenter: name.verticalCenter
            text: defined(root.user) ? to_s(root.user.screen_name, '@%1') : ''
            font.pixelSize: constants.fontSmall
            font.family: constants.fontFamily
            color: constants.nameColor
        }

        Column {
            id: contentArea
            anchors.left: iconArea.right
            anchors.leftMargin: constants.listViewMargins
            anchors.right: parent.right
            anchors.top: name.bottom

            Text {
                id: text
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                color: constants.contentColor
                font.pixelSize: constants.fontDefault
                font.family: constants.fontFamily
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.2
            }
        }
    }
}
