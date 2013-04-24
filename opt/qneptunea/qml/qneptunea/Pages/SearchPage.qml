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
import '../Views'
import '../Delegates'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: unescape(root.id_str)
    busy: model.loading || savedSearchesModel.loading

    property int __topIndex: view.indexAt(0, view.contentY)
    property variant __topData: model.get(__topIndex)

    StateGroup {
        states: [
            State {
                name: "show time"
                when: view.moving && __topData.created_at
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

    SearchListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        highlightRangeMode: ListView.NoHighlightRange
        header: Item {}
        model: SearchModel {
            id: model
            q: unescape(root.id_str)
            result_type: 'recent'
            count: 100
            sortKey: 'id_str'
        }
        onReload: {
            model.since_id = model.size == 0 ? '' : model.get(0).id_str
            model.until = ''
            model.reload()
        }
        onMore: {
            model.since_id = ''
            model.until = model.size == 0 ? '' : model.get(model.size - 1).id_str
            model.reload()
        }
        onShowDetail: pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: root.openLink(link)
    }

    Menu {
        id: menu
        visualParent: view
        property int savedIndex: savedSearchesModel.searchTerms.indexOf(unescape(root.id_str).toLowerCase())
        MenuLayout {
            MenuItemWithIcon {
                property bool muted: window.filters.indexOf(root.id_str) > -1
                iconSource: 'image://theme/icon-m-toolbar-volume'.concat(muted ? '' : '-off').concat(theme.inverted ? "-white" : "")
                text: muted ? qsTr('Unmute %1').arg(root.id_str) : qsTr('Mute %1').arg(root.id_str)
                onClicked: {
                    var filters = window.filters
                    if (muted) {
                        var index = filters.indexOf(root.id_str)
                        while (index > -1) {
                            filters.splice(index, 1)
                            index = filters.indexOf(root.id_str)
                        }
                    } else {
                        filters.unshift(root.id_str)
                    }
                    window.filters = filters
                }
            }
            MenuItemWithIcon {
                property bool saved: menu.savedIndex < 0
                iconSource: 'image://theme/icon-m-toolbar-favorite'.concat(saved ? '-unmark' : '-mark').concat(theme.inverted ? "-white" : "")
                text: saved ? qsTr('Save search') : qsTr('Remove saved search')
                onClicked: {
                    if (saved)
                        savedSearchesModel.createSavedSearch({'query': unescape(root.id_str)})
                    else
                        savedSearchesModel.destroySavedSearch({'id': savedSearchesModel.get(menu.savedIndex).id})
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'image://theme/icon-l-search'
            shortcutUrl: 'search://%1/%2'.arg(id_str).arg(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (menu.status === DialogStatus.Closed)
                    menu.open()
                else
                    menu.close()
            }
        }
        onClosing: menu.close()
    }
}
