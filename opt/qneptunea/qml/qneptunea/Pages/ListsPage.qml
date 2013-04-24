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
import '../Views'

AbstractPage {
    id: root

    title: to_s(screen_name, '@%1')
    busy: model.loading

    ListListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: ListsModel { id: model; user_id: root.id_str }
        onShowDetail: pageStack.push(listStatusesPage, {'id_str': detail.id_str, 'screen_name': detail.user.screen_name})
    }

//    Menu {
//        id: menu
//        visualParent: view
//        MenuLayout {
//            MenuItemWithIcon {
//                iconSource: 'image://theme/icon-m-toolbar-add'.concat(theme.inverted ? "-white" : "")
//                text: qsTr('Create')
//                onClicked: pageStack.push(listDetailPage)
//            }
//        }
//    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: to_s(profile_image_url).replace('_normal', '_bigger')
            shortcutUrl: 'lists://%1/%2'.arg(id_str).arg(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            enabled: false
//            enabled: root.id_str == oauth.user_id
            opacity: enabled ? 1.0 : 0.5
//            onClicked: {
//                if (menu.status == DialogStatus.Closed)
//                    menu.open()
//                else
//                    menu.close()
//            }
        }
//        onClosing: menu.close()
    }
}
