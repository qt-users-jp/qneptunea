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
import QNeptunea 1.0

AbstractPage {
    id: root

    property variant linkMenu: null
    property alias visualParent: menu.visualParent
    property StateGroup currentPlugin
    currentPluginLoading: currentPlugin ? currentPlugin.loading : false

    function message(text, icon) {
        infoBanners.message({'iconSource': icon, 'text': text})
    }

    Timer {
        running: typeof currentPlugin === 'object' && currentPlugin !== null && !currentPlugin.loading
        repeat: false
        interval: 10
        onTriggered: {
            var text = root.currentPlugin.message
            var icon = root.currentPlugin.icon
            if (text.length > 0)
                infoBanners.message({'text': text, 'iconSource': icon})
            root.currentPlugin = null
        }
    }

    signal headerClicked()

    User {
        id: userToOpen
        onIdStrChanged: {
            if (id_str.length > 0)
                pageStack.push(userPage, {'id_str': userToOpen.id_str})
        }
    }
    StateGroup {
        states: [
            State {
                when: userToOpen.loading
                PropertyChanges {
                    target: root
                    running: true
                }
            }
        ]
    }

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
        case /^https?:\/\/(mobile\.)?twitter\.com\/(#!\/)?[a-zA-z0-9_]+\/status\/([0-9]+)$/.test(link):
            pageStack.push(statusPage, {'id_str': RegExp.$3})
            break
        case /^https?:\/\/(mobile\.)?twitter\.com\/(#!\/)?([a-zA-z0-9_]+)$/.test(link):
            if (userToOpen.screen_name === RegExp.$3 && !userToOpen.loading && userToOpen.id_str.length > 0)
                pageStack.push(userPage, {'id_str': userToOpen.id_str})
            else
                userToOpen.screen_name = RegExp.$3
            break
        default:
            if (!root.linkMenu) {
                root.linkMenu = menu
                menu.link = link
                if (typeof parameters === 'undefined')
                    parameters = {'openLink': true }
                else
                    parameters.openLink = true
                menu.parameters = parameters
                menu.open()
            }
            break
        }
    }

    Menu {
        id: menu
        property url link
        property variant parameters

        MenuLayout {
            id: layout
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-l-browser-main-view'
                text: qsTr('Open in the browser')
                onClicked: {
                    root.running = true
                    Qt.openUrlExternally(menu.link)
                }
                Component.onCompleted: console.debug('parent0', parent)
            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-application'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Open in the default app')
                onClicked: {
                    root.running = true
                    ActionHandler.openUrlExternally(menu.link)
                }
            }

            Repeater {
                model: servicePlugins.pluginInfo
                delegate: MenuItemWithIcon {
                    id: customItem
                    iconSource: model.plugin.icon
                    text: model.plugin.service
                    visible: model.plugin.matches(menu.link)
                    onClicked: {
                        root.currentPlugin = plugin
                        model.plugin.open(menu.link, menu.parameters)
                    }
                }
            }
        }
        property bool __completed: false
        onStatusChanged: {
            if (menu.__completed && menu.status === DialogStatus.Closed) {
                root.linkMenu = null
            }
        }
        Component.onCompleted: menu.__completed = true
    }
}
