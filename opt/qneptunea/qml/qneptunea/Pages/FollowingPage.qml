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
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: to_s(screen_name, '@%1')
    busy: friendModel.loading || model.loading

    UserListView {
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: UsersModel {
            id: friendModel

            FriendsModel {
                id: model
                user_id: root.id_str
                property variant ids: []
                onSizeChanged: {
                    var ids = []
                    for (var i = 0; i < model.size; i++) {
                        ids.push(model.get(i).id_str ? model.get(i).id_str : model.get(i).id)
                    }
//                    console.debug(ids)
                    model.ids = ids
                }

                Timer {
                    running: model.ids.length > 0 && !friendModel.loading
                    interval: 100
                    repeat: true
                    onTriggered: {
//                        console.debug('triggered')
                        var ids = model.ids
                        var user_id = []
                        for (var i = 0; i < 100 && ids.length > 0; i++) {
                            user_id.push(ids.shift())
                        }
//                        console.debug(user_id)
                        model.ids = ids
                        friendModel.user_id = user_id.join(',')
                        friendModel.reload();
                    }
                }
            }
        }
        onShowDetail: pageStack.push(userPage, {'id_str': detail.id_str})
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=bigger'.arg(screen_name)
            shortcutUrl: 'following://%1/%2'.arg(id_str).arg(screen_name)
        }
        ToolSpacer {}
    }
}
