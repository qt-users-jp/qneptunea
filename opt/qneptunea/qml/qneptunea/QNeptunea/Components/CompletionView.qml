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

ListView {
    id: root
    width: 200
    height: 240
    clip: true

    property bool icon: false
    property string filter
    signal clicked(string candidate)

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutExpo }
    }

    delegate: MouseArea {
        id: delegate
        width: root.width
        height: active ? 48 : 0
        property bool active: model.key.substring(0, root.filter.length - 1).toLowerCase() === root.filter.substring(1).toLowerCase()
        clip: true

        Behavior on height {
            NumberAnimation { easing.type: Easing.OutExpo }
        }

        ProfileImage {
            id: avatar
            width: root.icon ? 48 : 0
            height: 48
            source: root.icon ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(model.key) : ''
            visible: delegate.active
        }
        Text {
            anchors.left: avatar.right
            anchors.leftMargin: constants.listViewMargins
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 24
            font.family: constants.fontFamily
            text: (root.icon ? '@' : '#').concat(model.key)
            elide: Text.ElideRight
            visible: delegate.active
        }
        onClicked: root.clicked(model.key)
    }
    Rectangle { anchors.fill: parent; color: 'white'; z: -1 }
}
