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
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Preview')
    busy: preview.status != Image.Ready

    property string type
    property alias url: preview.source

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentWidth: 500
        contentHeight: 500
        clip: true

        PinchArea {
            width: Math.max(container.contentWidth, container.width)
            height: Math.max(container.contentHeight, container.height)

            property real initialWidth
            property real initialHeight
            onPinchStarted: {
                initialWidth = container.contentWidth
                initialHeight = container.contentHeight
            }

            onPinchUpdated: {
                // adjust content pos due to drag
                container.contentX += pinch.previousCenter.x - pinch.center.x
                container.contentY += pinch.previousCenter.y - pinch.center.y

                // resize content
                container.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
            }

            onPinchFinished: {
                // Move its content within bounds.
                container.returnToBounds()
            }

            Item {
                width: container.contentWidth
                height: container.contentHeight

                AnimatedImage {
                    id: preview
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    anchors.fill: parent
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            container.contentWidth = 500
                            container.contentHeight = 500
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: container
    }

    ProgressBar {
        id: progress
        anchors.centerIn: container
        width: container.width / 2
        minimumValue: 0
        maximumValue: 100
        value: preview.progress * 100
        Behavior on value { SmoothedAnimation { velocity: 50 } }
        visible: preview.status == Image.Loading
        indeterminate: true

        states: [
            State {
                name: "loading"
                when: progress.value > 0
                PropertyChanges {
                    target: progress
                    indeterminate: false
                }
            }
        ]
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
