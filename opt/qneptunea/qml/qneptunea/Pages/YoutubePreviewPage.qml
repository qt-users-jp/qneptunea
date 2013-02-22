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
import QtMultimediaKit 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.1
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Youtube')
    busy: true

    property string type
    property string _id

    Video {
        id: video
        anchors { left: parent.left; top: parent.top; topMargin: root.headerHeight; right: parent.right }
        height: width * 3 / 4
        z: 1

        onSourceChanged: play()

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: video.fillMode = (video.fillMode === Video.PreserveAspectFit ? Video.PreserveAspectCrop : Video.PreserveAspectFit)
        }

        Rectangle {
            anchors.fill: parent
            z: -1
            color: 'black'
        }
    }

    ProgressBar {
        id: progressBar
        anchors { left: parent.left; right: parent.right; top: video.bottom; topMargin: -height / 2 }
        indeterminate: true
    }


    Flickable {
        id: container
        anchors { left: parent.left; top: progressBar.bottom; right: parent.right; bottom: parent.bottom; bottomMargin: root.footerHeight }
        clip: true
        contentHeight: description.height
        Label {
            id: description
            width: root.width
            wrapMode: Text.Wrap
        }
    }

    ScrollDecorator {
        flickableItem: container
    }

    toolBarLayout: AbstractToolBarLayout {
        id: toolBarLayout
        ToolSpacer {columns: 3}
        ToolIcon {
            id: pause
            iconSource: 'image://theme/icon-m-toolbar-mediacontrol-play'.concat(theme.inverted ? "-white" : "")
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                video.paused = !video.paused;
            }

            states: [
                State {
                    when: !video.paused
                    PropertyChanges {
                        target: pause
                        iconSource: 'image://theme/icon-m-toolbar-mediacontrol-pause'.concat(theme.inverted ? "-white" : "")
                    }
                }
            ]
        }
        onClosing: video.stop()
    }

    XmlListModel {
        id: youtube
        source: 'http://gdata.youtube.com/feeds/api/videos/'.concat(root._id)
        query: "/entry/media:group"
        namespaceDeclarations: 'declare default element namespace "http://www.w3.org/2005/Atom"; declare namespace media="http://search.yahoo.com/mrss/"; declare namespace yt="http://gdata.youtube.com/schemas/2007";'

        XmlRole { name: 'title'; query: 'media:title/string()' }
        XmlRole { name: 'description'; query: 'media:description/string()' }
        XmlRole { name: 'content'; query: "media:content[@type = 'video/3gpp'][2]/@url/string()" }
        XmlRole { name: 'duration'; query: "media:content[@type = 'video/3gpp'][2]/@duration/number()" }
    }

    StateGroup {
        states: [
            State {
                when: youtube.status === XmlListModel.Ready && youtube.count > 0
                PropertyChanges {
                    target: root
                    title: youtube.get(0).title
                    busy: false
                }
                PropertyChanges {
                    target: description
                    text: youtube.get(0).description
                }
                PropertyChanges {
                    target: video
                    source: youtube.get(0).content
                }
            }
        ]
    }
    StateGroup {
        states: [
            State {
                when: youtube.status === XmlListModel.Ready && youtube.count > 0 && video.status === Video.Buffered
                PropertyChanges {
                    target: progressBar
                    value: video.position
                    maximumValue: youtube.get(0).duration * 1000
                    indeterminate: false
                }
            }
        ]
    }

    StateGroup {
        id: orientation
        states: [
            State {
                when: !window.inPortrait
                AnchorChanges {
                    target: video
                    anchors.bottom: root.bottom
                }
                PropertyChanges {
                    target: window
                    logoVisible: false
                }
                PropertyChanges {
                    target: video
                    anchors.topMargin: 0
                }
                PropertyChanges {
                    target: root
                    footerOpacity: 0
                }
                PropertyChanges {
                    target: progressBar
                    visible: false
                }
            }
        ]
    }
}
