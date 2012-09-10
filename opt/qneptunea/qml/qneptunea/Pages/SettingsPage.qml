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
import '../QNeptunea/Components/'

AbstractLinkPage {
    id: root

    TabGroup {
        id: group
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        clip: true
        currentTab: connectivity

        SettingsPageConnectivityTab {
            id: connectivity
            pageStack: root.pageStack
        }

        SettingsPageAppearanceTab {
            id: appearance
            pageStack: root.pageStack
        }

        SettingsPagePluginsTab {
            id: plugins
            pageStack: root.pageStack
        }

        SettingsPageMiscTab {
            id: misc
            pageStack: root.pageStack
            interactive: !defined(root.linkMenu)
            onLinkActivated: root.openLink(link)
        }

        onCurrentTabChanged: if (root.linkMenu) root.linkMenu.close()
    }

    toolBarLayout: AbstractToolBarLayout {
        ButtonRow {
            TabButton {
                iconSource: 'image://theme/icon-m-toolbar-refresh'.concat(theme.inverted ? "-white" : "")
                tab: connectivity
                checked: true
            }

            TabButton {
                iconSource: 'image://theme/icon-m-toolbar-gallery'.concat(theme.inverted ? "-white" : "")
                tab: appearance
            }

            TabButton {
                iconSource: 'image://theme/icon-m-toolbar-settings'.concat(theme.inverted ? "-white" : "")
                tab: plugins
            }

            TabButton {
                iconSource: 'image://theme/icon-m-toolbar-list'.concat(theme.inverted ? "-white" : "")
                tab: misc
                onClicked: {
                    onClicked: {
                        if (root.linkMenu) {
                            root.linkMenu.close()
                        } else {
                            privatePressed()
                        }
                    }
                }
            }
        }
        onClosing: {
            if (root.linkMenu) root.linkMenu.close()
        }
    }

    states: [
        State {
            name: 'connectivity'
            when: group.currentTab === connectivity
            PropertyChanges { target: root; title: qsTr('Connectivity') }
        },
        State {
            name: 'appearance'
            when: group.currentTab === appearance
            PropertyChanges { target: root; title: qsTr('Appearance'); busy: appearance.loading }
        },
        State {
            name: 'plugins'
            when: group.currentTab === plugins
            PropertyChanges { target: root; title: qsTr('Plugins') }
        },
        State {
            name: 'misc'
            when: group.currentTab === misc
            PropertyChanges { target: root; title: qsTr('Misc'); visualParent: misc }
        }
    ]
}
