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
import Twitter4QML 1.0
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
    property string translated: __pluginItem ? __pluginItem.result : ''

    function translate() {
        var plugin = translationPlugins.pluginMap['Microsoft Translator V2']
//        console.debug(plugin)
        if (typeof plugin !== 'undefined') {
            var component = Qt.createComponent(plugin)
            if (component.status === Component.Ready) {
                var lang = LANG
                if (lang.indexOf('_') > -1)
                    lang = lang.substring(0, lang.indexOf('_'))
                root.__pluginItem = component.createObject(root)
                root.__pluginItem.translate('<html><body>'.concat(root.user.description).concat('</body></html>'), root.user.description, lang)
            } else {
                console.debug(component.errorString())
            }
        } else {
            console.debug('plugin not found')
        }
    }

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        height: detailArea.y + detailArea.height + 10 + 2

        Item {
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
                    source: user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=bigger') : ''
                    _id: user.profile_image_url ? user.profile_image_url : ''

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
            }

            Column {
                id: nameArea
                anchors.left: iconArea.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: constants.listViewMargins

                Text {
                    text: user.name ? user.name : ''
                    textFormat: Text.PlainText
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Row {
                    spacing: constants.fontDefault
                    Text {
                        text: user.screen_name ? '@' + user.screen_name : ''
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
                opacity: translated.length > 0 ? 0.75 : 1.0
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: translated
                visible: translated.length > 0
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontLarge * 1.40
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                onLinkActivated: root.linkActivated(link)
            }

            Text {
                width: parent.width
                text: '<a style="'.concat(constants.placeStyle).concat('" href="').concat(user.location).concat('">').concat(user.location).concat('</a>')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSmall
                color: constants.textColor
            }
            Text {
                width: parent.width
                text: '<a style="'.concat(constants.linkStyle).concat('" href="').concat(user.url).concat('">').concat(user.url).concat('</a>')
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
