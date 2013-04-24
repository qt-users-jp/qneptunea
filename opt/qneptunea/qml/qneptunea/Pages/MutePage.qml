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
import com.nokia.extras 1.0
import Twitter4QML 1.1
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('Mute Settings')

    Flickable {
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        contentHeight: filters.height
        clip: true
        TextArea {
            id: filters
            width: parent.width
            placeholderText: qsTr('@selop\n#Lumia\nhttp://nokia.ly/\nHTML5\n...')
            text: window.filters.join('\n')
            platformStyle: TextAreaStyle { textFont.pixelSize: constants.fontDefault }

            states: [
                State {
                    name: "empty"
                    when: filters.text.length == 0
                    PropertyChanges {
                        target: filters
                        implicitHeight: constants.fontDefault * 10
                    }
                }
            ]
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolButtonRow {
            ToolButton {
                id: button

                checked: enabled
                text: qsTr('Save')

                function save() {
                    root.busy = true
                    window.filters = filters.text.split(/\n/)
                    pageStack.pop()
                    root.busy = true
                }

                onClicked: save()
            }
        }
        ToolSpacer {}
//        ToolIcon {
//            platformIconId: "toolbar-view-menu"
//            enabled: typeof root.linkMenu !== 'undefined'
//            opacity: enabled ? 1.0 : 0.5
//            onClicked: {
//                root.linkMenu.close()
//            }
//        }
    }
}
