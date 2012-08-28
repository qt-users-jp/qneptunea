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
import QtWebKit 1.0
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Map')
    busy: map.loading

    property double _lat
    property double _long

    WebView {
        id: map
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        preferredWidth: width
        preferredHeight: height
        url: 'GoogleMaps.html'

        property bool loading: false
        onLoadStarted: loading = true
        onLoadFinished: loading = false
        onAlert: console.debug('alert:', message)

        javaScriptWindowObjects: QtObject {
            id: js
            WebView.windowObjectName: "qml"
            property real lat: root._lat
            property real lng: root._long
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        ToolIcon {
            iconSource: '../images/zoom-in'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: map.evaluateJavaScript('zoomIn()')
        }
        ToolIcon {
            iconSource: '../images/zoom-out'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: map.evaluateJavaScript('zoomOut()')
        }
    }
}
