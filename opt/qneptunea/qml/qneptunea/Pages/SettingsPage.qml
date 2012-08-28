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
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    SettingsPageConnectivityTab {
        id: connectivity
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: connectivity }

    SettingsPageAppearanceTab {
        id: appearance
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: appearance }

    SettingsPagePluginsTab {
        id: plugins
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: plugins }

    SettingsPageMiscTab {
        id: misc
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: misc }

    toolBarLayout: AbstractToolBarLayout {
        ButtonRow {
            TabButton {
                id: showConnectivity
                iconSource: 'image://theme/icon-m-toolbar-refresh'.concat(theme.inverted ? "-white" : "")
                checkable: true
                checked: true
            }

            TabButton {
                id: showAppearance
                iconSource: 'image://theme/icon-m-toolbar-gallery'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }

            TabButton {
                id: showPlugins
                iconSource: 'image://theme/icon-m-toolbar-settings'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }

            TabButton {
                id: showMisc
                iconSource: 'image://theme/icon-m-toolbar-list'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }
        }
    }

    states: [
        State {
            name: 'connectivity'
            when: showConnectivity.checked
            PropertyChanges { target: root; title: qsTr('Connectivity') }
            PropertyChanges { target: connectivity; opacity: 1; status: root.status }
        },
        State {
            name: 'appearance'
            when: showAppearance.checked
            PropertyChanges { target: root; title: qsTr('Appearance'); busy: appearance.loading }
            PropertyChanges { target: appearance; opacity: 1; status: root.status }
        },
        State {
            name: 'plugins'
            when: showPlugins.checked
            PropertyChanges { target: root; title: qsTr('Plugins') }
            PropertyChanges { target: plugins; opacity: 1; status: root.status }
        },
        State {
            name: 'misc'
            when: showMisc.checked
            PropertyChanges { target: root; title: qsTr('Misc') }
            PropertyChanges { target: misc; opacity: 1; status: root.status }
        }
    ]

    transitions: [
        Transition {
            from: 'connectivity'
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: 'appearance'
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "plugins"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "misc"
            NumberAnimation { properties: 'opacity' }
        }
    ]
}
