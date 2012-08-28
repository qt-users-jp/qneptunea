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

MouseArea {
    id: root
    width: 200
    height: 200
    visible: false
    property string url
    property string type: root.__pluginItem && root.__pluginItem.type ? root.__pluginItem.type : ''
    property StateGroup __pluginItem

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: image
        SpinnerImage {
            anchors.fill: parent
            source: root.__pluginItem.thumbnail
            fillMode: Image.PreserveAspectCrop
            clip: true
            smooth: true
            cache: false
        }
    }

    states: [
        State {
            name: "image"
            when: root.type === 'image' || root.type === 'youtube' || root.type === 'slideshare'
            PropertyChanges { target: loader; sourceComponent: image }
            PropertyChanges { target: root; visible: true }
        },
        State {
            name: "url"
            when: root.type == 'url' && root.__pluginItem.url.length > 0
            PropertyChanges { target: urlUpdate; running: true }
        }
    ]
    Timer {
        id: urlUpdate
        interval: 10
        repeat: false
        running: false
        onTriggered: {
            root.url = root.__pluginItem.url
//            root.__pluginItem.destroy(10)
        }
    }

//    Text {
//        anchors.fill: parent
//        text: root.url
//        styleColor: "#ffffff"
//        wrapMode: Text.WrapAnywhere
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        style: Text.Outline
//        font.pixelSize: constants.fontDefault
//    }

    onClicked: {
        if (root.type == 'web')
            root.parent.openLink(root.__pluginItem.detail)
        else if (root.type == 'image')
            pageStack.push(imagePreviewPage, {'type': root.__pluginItem.type, 'url': root.__pluginItem.detail})
        else if (root.type == 'youtube')
            pageStack.push(youtubePreviewPage, {'type': root.__pluginItem.type, '_id': root.__pluginItem._id})
        else if (root.type == 'slideshare')
            pageStack.push(slidesharePreviewPage, {'type': root.__pluginItem.type, '_id': root.__pluginItem._id})
    }

    function update() {
        console.debug('update', root.url)
        var a = root.url.split('/')
        a.shift() // http:
        a.shift() //
        var domain = a.shift()
        var parameters = a.join('/')
        console.debug(url, domain, parameters)
        var plugin = previewPlugins.pluginMap[domain]
//        console.debug(plugin)
        if (typeof plugin !== 'undefined') {
            var component = Qt.createComponent(plugin)
            if (component.status === Component.Ready) {
                root.__pluginItem = component.createObject(root)
                if (!root.__pluginItem.load(root.url, domain)) {
                    root.destroy()
                }
            } else {
                console.debug(component.errorString())
                root.destroy()
            }
        } else {
//            root.url = 'http://img.simpleapi.net/small/' + root.url
            root.destroy()
        }
    }

    onUrlChanged: {
        console.debug('onUrlChanged')
        update()
    }
//    Component.onCompleted: {
//        console.debug('onCompleted')
//        update()
//    }
}
