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

ToolIcon {
    id: root

    property string shortcutIcon
    property string shortcutUrl: 'page://'
    property int shortcutIndex: -1

    iconSource: 'image://theme/icon-m-toolbar-attachment'.concat(theme.inverted ? "-white" : "")

    opacity: enabled ? 1.0 : 0.5
    onClicked: {
        if (root.linkMenu) root.linkMenu.close()
        if (root.shortcutIndex < 0) {
            var gridId = -1
            for (var i = 0; i < shortcutModel.count; i++) {
                gridId = Math.max(gridId, shortcutModel.get(i).gridId)
            }

            shortcutModel.append({'icon': root.shortcutIcon, 'link': root.shortcutUrl, 'gridId': gridId + 1})
            window.shortcutAdded = true
            root.parent.closing()
            pageStack.pop(mainPage)
        } else {
            shortcutModel.remove(root.shortcutIndex)
        }
        root.checkIndex()
    }

    states: [
        State {
            name: 'added'
            when: root.shortcutIndex > -1
            PropertyChanges {
                target: root
                iconSource: 'image://theme/icon-m-toolbar-attachment'.concat(theme.inverted ? "-white-selected" : "-selected")
            }
        },
        State {
            when: shortcutModel.count == 6
            PropertyChanges { target: root; enabled: false }
        }
    ]
    Component.onCompleted: checkIndex()

    function checkIndex() {
        root.shortcutIndex = -1
        for (var i = 0; i < shortcutModel.count; i++) {
            if (shortcutModel.get(i).link == shortcutUrl) {
                root.shortcutIndex = i
                break
            }
        }
    }
}
