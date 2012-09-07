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
import '../Delegates'
import '../QNeptunea/Components/'

AbstractLinkPage {
    id: root

    title: qsTr('DirectMessage')
    busy: direct_message.loading
    visualParent: container

    DirectMessage {
        id: direct_message
        id_str: root.id_str
        onIdStrChanged: {
            if (id_str.length == 0 && root.status === PageStatus.Active)
                pageStack.pop()
        }
    }

    Item {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        clip: true

        DirectMessageDetailDelegate {
            id: delegate
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            item: direct_message
            sender: direct_message.sender
            recipient: direct_message.recipient
            onLinkActivated: root.openLink(link)
            onUserClicked: pageStack.push(userPage, {'id_str': user.id_str})

            Behavior on height {
                NumberAnimation {}
            }
        }
    }

    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            MenuItemWithIcon {
                id: copy
                iconSource: 'image://theme/icon-m-toolbar-tag'.concat(enabled ? "" : "-dimmed").concat(theme.inverted ? "-white" : "")
                text: qsTr('Copy to clipboard')
                onClicked: {
                    clipboard.text = direct_message.text
                    clipboard.selectAll()
                    clipboard.cut()
                }
            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-delete'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Delete')
                onClicked: direct_message.destroyDirectMessage()
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {}

        ToolIcon {
            platformIconId: "toolbar-reply"
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                var parameters = {}
                parameters['in_reply_to'] = direct_message.data
                if (direct_message.recipient_id == oauth.user_id) {
                    parameters['recipient'] = direct_message.sender
                } else {
                    parameters['recipient'] = direct_message.recipient
                }
                pageStack.push(sendDirectMessagePage, parameters)
            }
        }

        ToolSpacer {}

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                if (root.linkMenu) {
                    root.linkMenu.close()
                } else {
                    if (menu.status === DialogStatus.Closed)
                        menu.open()
                    else
                        menu.close()
                }
            }
        }
    }
}
