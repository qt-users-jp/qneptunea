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
import "../Delegates"

AbstractListView {
    id: root
    width: 400
    height: 700

    property bool active: false

    delegate: StatusDelegate {
        id: delegate
        width: ListView.view.width
        item: model
        user: model.user
        onClicked: root.showDetail(item)
        onLinkActivated: root.linkActivated(link)

        onPressAndHold: {
            console.debug(model.text)
            console.debug(model.plain_text)
            console.debug(model.rich_text)
            console.debug('http://twitter.com/' + model.user.screen_name + '/' + model.id_str)
        }

        property int height2: delegate.height
        property bool wasAtYBeginning: false

        ListView.onAdd: SequentialAnimation {
            ScriptAction {
                script: {
                    delegate.wasAtYBeginning = delegate.ListView.view.atYBeginning && !root.active
                    if (delegate.wasAtYBeginning) delegate.ListView.view.contentY += 1
                }
            }
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "height2"; value: height }
            PropertyAction { target: delegate; property: "height"; value: 0 }
            NumberAnimation { target: delegate; property: "height"; to: delegate.height2; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "clip"; value: false }
            ScriptAction { script: if (delegate.wasAtYBeginning) delegate.ListView.view.contentY -= 1 }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: delegate; property: "height"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: delegate; property: "clip"; value: false }
        }
    }
}
