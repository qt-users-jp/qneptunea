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
import Twitter4QML 1.1
import "../Delegates"

AbstractListView {
    id: root
    width: 400
    height: 700

    property bool active: false
    property bool __pressed: false

    Connections { target: root; onActiveChanged: actions.parent = root }

    Status { id: status }

    ActionBar {
        id: actions
        width: height * 3 * 1.25
        enabled: !status.loading

        property bool __retweeted: typeof status.retweeted_status.id_str !== 'undefined'
        property variant __status: __retweeted ? status.retweeted_status : status
        property variant __user: __status.user

        Button {
            iconSource: 'image://theme/icon-m-toolbar-reply'.concat(theme.inverted ? '' : '-white')
            onClicked: {
                var entities = actions.__status.entities
                var statusText = '@'.concat(actions.__user.screen_name).concat(' ')
                if (typeof entities.user_mentions.length !== 'undefined') {
                    for (var j = 0; j < entities.user_mentions.length; j++) {
                        var id_str = entities.user_mentions[j].id_str
                        if (id_str !== actions.__user.id_str && id_str !== oauth.user_id) {
                            statusText = statusText.concat('@').concat(entities.user_mentions[j].screen_name).concat(' ')
                        }
                    }
                }
                if (typeof entities.hashtags.length !== 'undefined') {
                    for (var j = 0; j < entities.hashtags.length; j++) {
                        statusText = statusText.concat(' #').concat(entities.hashtags[j].text)
                    }
                }
                actions.parent = root
                pageStack.push(tweetPage, {'statusText': statusText, 'in_reply_to': actions.__status})
            }
        }
        Button {
            iconSource: '../images/retweet'.concat(theme.inverted ? '.png' : '-white.png')
            enabled: typeof actions.__status !== 'undefined'
            opacity: enabled ? 1.0 : 0.75
            onClicked: {
                if (actions.__status.retweeted) {
                    status.destroyStatuses()
                } else {
                    if (actions.__status.user.id_str == oauth.user_id) {
                        pageStack.push(tweetPage, {'statusText': ' RT @%1: %2'.arg(actions.__status.user.screen_name).arg(actions.__status.text.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')), 'in_reply_to': actions.__status})
                    } else {
                        pageStack.push(tweetPage, {'in_reply_to': actions.__status})
                    }
                }
                actions.parent = root
            }
        }
        Button {
            id: favorite
            iconSource: 'image://theme/icon-m-toolbar-favorite-unmark'.concat(theme.inverted ? '' : '-white')
            onClicked: {
                if (status.favorited)
                    status.unfavorite()
                else
                    status.favorite()
                actions.parent = root
            }
            states: [
                State {
                    name: "favorited"
                    when: actions.__status.favorited
                    PropertyChanges {
                        target: favorite
                        iconSource: 'image://theme/icon-m-toolbar-favorite-mark'.concat(theme.inverted ? '' : '-white')
                    }
                }
            ]
        }
    }

    onMovementStarted: {
        actions.parent = root
    }

    delegate: StatusDelegate {
        id: delegate
        width: ListView.view.width
        item: model
        onClicked: root.showDetail(item)
        onLinkActivated: root.linkActivated(link)

        onPressed: {
            actions.parent = root
            root.__pressed = true
        }

        onPressAndHold: {
//            if (!currentVersion.trusted) return
            status.id_str = model.id_str
            actions.parent = delegate
            if (mouse.x < delegate.width / 2) {
                actions.x = Math.min(mouse.x + actions.height, delegate.width - actions.width - actions.height)
            } else {
                actions.x = Math.max(actions.height, mouse.x - actions.width - actions.height)
            }
            actions.y = Math.max(0, mouse.y - actions.height * 2)
        }

        onCanceled: root.__pressed = false
        onReleased: root.__pressed = false

        property int height2: delegate.height
        property bool wasAtYBeginning: false

        ListView.onAdd: SequentialAnimation {
            ScriptAction {
                script: {
                    delegate.wasAtYBeginning = delegate.ListView.view.atYBeginning && (!root.active || root.__pressed)
                    if (delegate.wasAtYBeginning) delegate.ListView.view.contentY += 1
                }
            }
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "height2"; value: height }
            PropertyAction { target: delegate; property: "height"; value: 0 }
            NumberAnimation { target: delegate; property: "height"; to: delegate.height2; duration: 128; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "clip"; value: false }
            ScriptAction { script: if (delegate.wasAtYBeginning) delegate.ListView.view.contentY -= 1 }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: delegate; property: "height"; to: 0; duration: 128; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: delegate; property: "clip"; value: false }
        }

        Component.onDestruction: if (actions.parent === delegate) actions.parent = root
    }
}
