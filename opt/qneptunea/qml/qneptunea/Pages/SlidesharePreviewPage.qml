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
import QtWebKit 1.0
import com.nokia.meego 1.0
import Twitter4QML 1.1
import '../QNeptunea/Components/'
import '../Utils/sha1.js' as Sha1

AbstractPage {
    id: root

    title: qsTr('SlideShare')
    busy: true

    property string type
    property string _id
    property string api_key: 'k31SJf4M'
    property string sharedsecret: 'dailbs8X'

    Component.onCompleted: {
        var base_url = 'http://www.slideshare.net/api/2/get_slideshow'
        var param = {'slideshow_id': root._id, 'api_key': root.api_key}
        var ts = new Date()
        param.ts = ts.getTime() / 1000
        param.hash = Sha1.hex_sha1(root.sharedsecret.concat(param.ts))

        var arr = new Array()
        for (var i in param) {
            arr.push(i.concat('=').concat(encodeURIComponent(param[i])))
        }

        slideshare.source = base_url.concat('?').concat(arr.join('&'))
    }

    WebView {
        id: view
        anchors { left: parent.left; top: parent.top; topMargin: root.headerHeight; right: parent.right }
        height: width * 3 / 4
        preferredWidth: width
        preferredHeight: height
        z: 1
    }

    Flickable {
        id: container
        anchors { left: parent.left; top: view.bottom; right: parent.right; bottom: parent.bottom; bottomMargin: root.footerHeight }
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
            id: download
            iconSource: 'image://theme/icon-m-toolbar-directory-move-to'.concat(theme.inverted ? "-white" : "")
            enabled: false
            opacity: enabled ? 1.0 : 0.5
            onClicked: Qt.openUrlExternally(slideshare.get(0).DownloadUrl)
        }
    }

    XmlListModel {
        id: slideshare
        query: '/Slideshow'

        XmlRole { name: 'ID'; query: 'ID/string()' }
        XmlRole { name: 'Title'; query: 'Title/string()' }
        XmlRole { name: 'Description'; query: 'Description/string()' }
        XmlRole { name: 'Status'; query: 'Status/number()' }
        XmlRole { name: 'Username'; query: 'Username/string()' }
        XmlRole { name: 'URL'; query: 'URL/string()' }
        XmlRole { name: 'ThumbnailURL'; query: 'ThumbnailURL/string()' }
        XmlRole { name: 'ThumbnailSmallURL'; query: 'ThumbnailSmallURL/string()' }
        XmlRole { name: 'Embed'; query: 'Embed/string()' }
        XmlRole { name: 'Created'; query: 'Created/string()' }
        XmlRole { name: 'Updated'; query: 'Updated/string()' }
        XmlRole { name: 'Language'; query: 'Language/string()' }
        XmlRole { name: 'Format'; query: 'Format/string()' }
        XmlRole { name: 'Download'; query: 'Download/number()' }
        XmlRole { name: 'DownloadUrl'; query: 'DownloadUrl/string()' }
        XmlRole { name: 'SlideshowType'; query: 'SlideshowType/number()' }
        XmlRole { name: 'InContest'; query: 'InContest/number()' }
    }

    StateGroup {
        states: [
            State {
                when: slideshare.status === XmlListModel.Ready && slideshare.count > 0
                PropertyChanges {
                    target: root
                    title: slideshare.get(0).Title
                    busy: false
                }
                PropertyChanges {
                    target: description
                    text: slideshare.get(0).Description
                }
                PropertyChanges {
                    target: view
                    url: 'http://www.slideshare.net/slideshow/embed_code/'.concat(slideshare.get(0).ID)
                }
                PropertyChanges {
                    target: download
                    enabled: slideshare.get(0).Download === 1
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
                    target: view
                    anchors.bottom: root.bottom
                }
                PropertyChanges {
                    target: window
                    logoVisible: false
                }
                PropertyChanges {
                    target: view
                    anchors.topMargin: 0
                }
                PropertyChanges {
                    target: root
                    footerOpacity: 0
                }
            }
        ]
    }
}
