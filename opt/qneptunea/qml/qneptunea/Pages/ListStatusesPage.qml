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
import Twitter4QML 1.1
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: list.full_name
    busy: statusesModel.loading || membersModel.loading

    List { id: list; id_str: root.id_str }

    property int __topIndex: statusesView.indexAt(0, statusesView.contentY)
    property variant __topData: statusesModel.get(__topIndex)

    StateGroup {
        states: [
            State {
                name: "show time"
                when: statusesView.moving && __topData.created_at
                PropertyChanges {
                    target: root
                    title: Qt.formatDateTime(new Date(__topData.created_at), constants.dateTimeFormat)
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    StatusListView {
        id: statusesView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: ListStatusesModel {
            id: statusesModel
            list_id: list.id_str
            sortKey: 'id_str'
            count: 100
        }
        onReload: {
            statusesModel.since_id = statusesModel.get(0).id_str
            statusesModel.max_id = ''
            statusesModel.reload()
        }
        onMore: {
            statusesModel.max_id = statusesModel.get(statusesModel.size - 1).id_str
            statusesModel.since_id = ''
            statusesModel.reload()
        }
        onShowDetail: pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: root.openLink(link)
        visible: opacity > 0
    }

    UserListView {
        id: membersView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: ListMembersModel {
            id: membersModel
            list_id: list.id_str
            property string max_cursor_str
            onNext_cursor_strChanged: {
//                console.debug('next_cursor_str', next_cursor_str)
                if (max_cursor_str < next_cursor_str)
                    max_cursor_str = next_cursor_str
            }
        }
        onReload: {
            membersModel.cursor = ''
            membersModel.reload()
        }
        onMore: {
            membersModel.cursor = membersModel.next_cursor_str
            membersModel.reload()
        }
        onShowDetail: pageStack.push(userPage, {'id_str': detail.id_str})
        visible: opacity > 0
    }

    Menu {
        id: menuOthers
        visualParent: statusesView
        MenuLayout {
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-favorite-'.concat(list.following ? 'mark' : 'unmark').concat(theme.inverted ? "-white" : "")
                text: list.following ? qsTr('Unsubscribe') : qsTr('Subscribe')
                enabled: !list.loading
                onClicked: {
                    if (list.following)
                        list.unsubscribe()
                    else
                        list.subscribe()
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolIcon {
            id: showStatuses
            platformIconId: "toolbar-list"
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                menuOthers.close()
                root.state = "statuses"
            }
        }
        ToolIcon {
            id: showMember
            platformIconId: "toolbar-contact"
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                menuOthers.close()
                root.state = "members"
            }
        }

        AddShortcutButton {
            shortcutIcon: to_s(profile_image_url).replace('_normal', '_bigger')
            shortcutUrl: 'list://'.concat(id_str).concat('/').concat(screen_name)
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            enabled: list.user.id_str !== oauth.user_id
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (menuOthers.status == DialogStatus.Closed)
                    menuOthers.open()
                else
                    menuOthers.close()
            }
        }
        onClosing: {
            menuOthers.close()
        }
    }

    state: 'statuses'
    states: [
        State {
            name: "statuses"
            PropertyChanges {
                target: membersView
                opacity: 0
            }
            PropertyChanges {
                target: showStatuses
                enabled: false
            }
            PropertyChanges {
                target: root
                busy: statusesModel.loading
            }
            PropertyChanges {
                target: menuOthers
                visualParent: statusesView
            }
        },
        State {
            name: "members"
            PropertyChanges {
                target: statusesView
                opacity: 0
            }
            PropertyChanges {
                target: showMember
                enabled: false
            }
            PropertyChanges {
                target: root
                busy: membersModel.loading
            }
            PropertyChanges {
                target: menuOthers
                visualParent: membersView
            }
        }
    ]

    transitions: [
        Transition {
            from: "members"
            to: "statuses"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "statuses"
            to: "members"
            NumberAnimation { properties: 'opacity' }
        }
    ]
}
