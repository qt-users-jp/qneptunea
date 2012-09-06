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
import '../QNeptunea/Components/'

AbstractDelegate {
    id: root
    width: 400

    property variant item
    property bool __retweeted: defined(root.item) && defined(root.item.retweeted_status) && defined(root.item.retweeted_status.user)
    property variant __item: __retweeted ? root.item.retweeted_status : root.item

    user: root.__item.user
    text: defined(root.__item) ? to_s(root.__item.plain_text) : ''

    Loader {
        id: place
        anchors.right: parent.right
        states: [
            State {
                when: defined(root.__item) && defined(root.__item.place) && defined(root.__item.place.full_name)
                PropertyChanges {
                    target: place
                    sourceComponent: placeComponent
                }
            }
        ]
        Binding {
            target: place.item
            property: 'place'
            value: root.__item.place
            when: place.status === Loader.Ready
        }
    }

    Loader {
        id: retweetedBy
        anchors.right: parent.right
        states: [
            State {
                when: root.__retweeted
                PropertyChanges {
                    target: retweetedBy
                    sourceComponent: retweetedByComponent
                }
            }
        ]
        Binding {
            target: retweetedBy.item
            property: 'user'
            value: root.item.user
            when: retweetedBy.status === Loader.Ready
        }
    }

    Component.onCompleted: {
        if (root.user.id_str === oauth.user_id) {
            root.separatorColor = constants.separatorFromMeColor
        } else if (defined(root.__item.entities)){
            var mentions = root.__item.entities.user_mentions
            for (var i = 0; i < mentions.length; i++) {
                if (mentions[i].screen_name === oauth.screen_name) {
                    root.separatorColor = constants.separatorToMeColor
                    break
                }
            }
        }
    }
}
