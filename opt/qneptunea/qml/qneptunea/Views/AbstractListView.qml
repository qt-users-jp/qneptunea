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
import '../QNeptunea/Components/'

ListView {
    id: root
    width: 400
    height: 700

    flickableDirection: Flickable.VerticalFlick
    clip: true

    property bool loading: false
    signal showDetail(variant detail)
    signal linkActivated(string link)

    property bool __wasAtYBeginning: false
    property int __scrollStartedAt: 0

    Connections {
        target: root
        onMovementStarted: {
            __wasAtYBeginning = atYBeginning
            __scrollStartedAt = contentY
            __toBeMore = false
            __toBeReload = false
        }
        onMovementEnded: {
            if (__toBeReload) {
                reload()
            }
            if (__toBeMore) {
                more()
            }
            __toBeMore = false
            __toBeReload = false
        }
    }

    property bool __toBeReload: false
    property bool __toBeMore: false
    signal reload()
    signal more()

    header: Item {
        id: header
        width: ListView.view.width
        height: 0
        states: [
            State {
                name: "refresh"
                when: header.ListView.view.__wasAtYBeginning && header.ListView.view.__scrollStartedAt - header.ListView.view.contentY > 100
                StateChangeScript {
                    script: header.ListView.view.__toBeReload = true
                }
            }
        ]
    }

    footer: Item {
        id: footer
        width: parent.width
        height: Math.max(constants.fontDefault, more.height) * 2
        clip: true
        opacity: root.loading ? 1.0 : 0.0
        Row {
            anchors.centerIn: parent
            spacing: 10

            BusyIndicator {
                id: more
                running: false
            }

            Label {
                text: qsTr('Loading...')
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
            }

            states: [
                State {
                    name: "refresh"
                    when: footer.ListView.view.atYEnd/* && footer.ListView.view.__scrollStartedAt - footer.ListView.view.contentY < 100*/
                    PropertyChanges {
                        target: more
                        running: true
                    }
                    StateChangeScript {
                        script: footer.ListView.view.__toBeMore = true
                    }
                }
            ]
        }
    }

    property int topItemIndex: Math.min(root.indexAt(0, root.contentY + 5) + 1, root.count) - 1

    onCountChanged: timer.changed = true
    onContentYChanged: timer.changed = true

    Timer {
        id: timer
        property bool changed: false
        interval: 100
        running: timer.changed
        repeat: false
        onTriggered: {
            root.topItemIndex = Math.min(root.indexAt(0, root.contentY + 5) + 1, root.count) - 1
            timer.changed = false
        }
    }

    ScrollBar {
        height: root.height * topItemIndex / 100
        target: root
        Behavior on height { SmoothedAnimation { velocity: 50 } }
    }
}
