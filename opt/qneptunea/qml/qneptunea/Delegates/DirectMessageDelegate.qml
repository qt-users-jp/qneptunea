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

AbstractDelegate {
    id: root
    width: 400

    property variant item

    user: defined(root.item) ? root.item.sender : undefined
    text: defined(root.item) ? to_s(root.item.plain_text) : ''
    separatorColor: defined(root.item) && root.item.sender.id_str === oauth.user_id ? constants.separatorFromMeColor : constants.separatorToMeColor

    Row {
        anchors.right: parent.right
        visible: defined(root.item) && (root.item.sender.id_str === oauth.user_id)
        spacing: constants.listViewMargins

        Text {
            text: defined(root.item) && defined(root.item.recipient) ? qsTr('Sent to %1').arg(to_s(root.item.recipient.name)) : ''
            anchors.bottom: parent.bottom
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontSmall
        }

        ProfileImage {
            id: icon
            width: constants.listViewIconSize / 2
            height: width
            source: defined(root.item) && defined(root.item.recipient) ? to_s(root.item.recipient.profile_image_url).replace('_normal', '_%1').arg(constants.listViewIconSizeName) : ''
            _id: icon.source

            smooth: true
        }
    }
}
