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

Row {
    id: root
    anchors.right: parent ? parent.right : undefined
    spacing: constants.listViewMargins
    property variant user

    Image {
        source: '../../images/retweet'.concat(theme.inverted ? '-white.png' : '.png')
        anchors.verticalCenter: parent.verticalCenter
        smooth: true
        width: constants.listViewIconSize / 2
        height: width
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: user.name ? user.name : ''
        textFormat: Text.PlainText
        color: constants.nameColor
        font.pixelSize: constants.fontSmall
        font.family: constants.fontFamily
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: constants.listViewIconSize / 2
        height: width + constants.listViewMargins
        ProfileImage {
            anchors.centerIn: parent
            width: constants.listViewIconSize / 2
            height: width
            source: user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
            _id: user.profile_image_url ? user.profile_image_url : ''
            smooth: true
        }
    }
}
