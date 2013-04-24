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
import com.nokia.meego 1.0

Page {
    id: root

    property string id_str
    property string screen_name
    property string profile_image_url

    property alias title: header.text
    property bool busy: false

    property int headerHeight: header.y + header.height
    property int footerHeight: footer.height * footerOpacity
    property alias toolBarLayout: footer.tools
    property alias footerOpacity: footer.opacity

    function openLink(link, parameters) {
        console.debug(link)
        switch (true) {
        case /^search:\/\//.test(link):
            pageStack.push(searchPage, {'id_str': link.substring(9)})
            break
        case /^user:\/\//.test(link):
            pageStack.push(userPage, {'id_str': link.substring(7)})
            break
        case /^status:\/\//.test(link):
            pageStack.push(statusPage, {'id_str': link.substring(8)})
            break
        }
    }

    function message(text, icon) {
        infoBanners.message({'iconSource': icon, 'text': text})
    }

    signal headerClicked()

    property bool running: false
    property bool currentPluginLoading: false
    Connections {
        target: platformWindow
        onActiveChanged: {
            if (!root.running) return;
            root.running = platformWindow.active
        }
    }

    TitleBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        busy: root.busy || root.running || root.currentPluginLoading
        onClicked: root.headerClicked()
    }

    ToolBar {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        states: [
            State {
                name: 'hidden'
                when: opacity == 0
                PropertyChanges {
                    target: footer
                    visible: false
                    height: 0
                }
            }
        ]
        transitions: [
            Transition {
                NumberAnimation { properties: 'height' }
            }
        ]
    }
}
