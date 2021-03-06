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

MouseArea {
    width: 100
    height: constants.fontDefault + 40

    property alias icon: icon.source
    property alias text: text.text
    property alias driilldown: drilldown.visible
    property alias separatorVisible: separator.visible
    property alias separatorColor: separator.color

    Item {
        id: iconArea
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        width: (icon.status === Image.Ready) ? 48 : 0
        height: 48
        Image {
            id: icon
            anchors.centerIn: parent
        }
    }

    Text {
        id: text
        anchors.left: iconArea.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font.bold: true
        font.family: constants.fontFamily
        font.pixelSize: constants.fontDefault
        color: constants.textColor
    }

    Image {
        id: drilldown
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        source: 'image://theme/icon-m-common-drilldown-arrow'.concat(theme.inverted ? "-inverse" : "")
    }

    Separator {
        id: separator
        anchors.left: parent.left
        anchors.leftMargin: constants.listViewMargins
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewMargins
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -constants.separatorHeight / 2
    }
}
