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
import Twitter4QML 1.1
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: list.name ? list.name : qsTr('Create')
    busy: list.loading

    List { id: list; id_str: root.id_str }

    Column {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        Text {
            text: qsTr('Name')
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            color: constants.textColor
        }
        TextField {
            id: name
            text: list.name ? list.name : ''
            width: parent.width
        }
        Text {
            text: qsTr('Description')
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            color: constants.textColor
        }
        TextArea {
            id: description
            text: list.description ? list.description : ''
            width: parent.width
        }
        ButtonRow {
            RadioButton {
                id: modePublic
                text: qsTr('Public')
                checked: list.mode ? list.mode == 'public' : true
            }
            RadioButton {
                id: modePrivate
                text: qsTr('Private')
                checked: list.mode ? list.mode == 'private' : false
            }
        }
    }

    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-add'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Create')
                enabled: false
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 3}
        ToolIcon {
            platformIconId: 'toolbar-done'
            onClicked: {
                if (list.id_str.length == 0) {
                    list.createLists({'name': name.text, 'description': description.text, 'mode': modePublic.checked ? 'public' : 'private' })
                } else {
                    list.updateLists({'list_id': list.id_str, 'name': name.text, 'description': description.text, 'mode': modePublic.checked ? 'public' : 'private' })
                }
            }
        }
    }
}
