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
import QtMobility.gallery 1.1
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Gallery')
    busy: model.status === DocumentGalleryModel.Active

    GridView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        cellWidth: 160
        cellHeight: 160
        cacheBuffer: Math.max(width, height) * 5
        clip: true

        delegate: Image {
            width: 160
            height: 160
            source: 'image://qneptunea/' + url
            asynchronous: true
            clip: true
            cache: false
            fillMode: Image.PreserveAspectCrop
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mediaSelected = url
                    pageStack.pop()
                }
            }
        }

        model: DocumentGalleryModel {
            id: model
            rootType: DocumentGallery.Image
            properties: ["url"]
            sortProperties: ["-lastModified"]
            filter: GalleryWildcardFilter {
                property: "fileName"
                value: "*.*"
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout { backOnly: true }
}
