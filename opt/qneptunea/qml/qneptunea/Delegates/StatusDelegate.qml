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
