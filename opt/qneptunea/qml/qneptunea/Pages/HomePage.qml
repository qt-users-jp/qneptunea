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
import QNeptunea 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: qsTr('Timeline')
    busy: homeTimeline.loading
    footerOpacity: 0
    onHeaderClicked: if (!homeTimeline.loading) view.positionViewAtBeginning()

    property bool active: false
    property string __maxReadIdStr: settings.readData('HomePage/maxReadIdStr', '')
    property variant topData: model.get(view.topItemIndex)
    onTopDataChanged: refresh.toBeRefreshed = true
    property int unreadCount: 0

    Timer {
        id: refresh
        property bool toBeRefreshed: true
        running: refresh.toBeRefreshed && platformWindow.visible && !homeTimeline.loading
        interval: 250
        repeat: false
        onTriggered: {
            if (view.count > 0) {
                var id_str = model.get(Math.max(0, view.topItemIndex)).id_str
                if (root.__maxReadIdStr.length < id_str.length) {
                    root.__maxReadIdStr = id_str
                } else if (root.__maxReadIdStr.length == id_str.length && root.__maxReadIdStr < id_str) {
                    root.__maxReadIdStr = id_str
                } else if (view.atYBeginning && root.__maxReadIdStr.length == 0) {
                    root.__maxReadIdStr = id_str
                }
                root.unreadCount = model.indexOf(root.__maxReadIdStr)
            }
            refresh.toBeRefreshed = false
        }
    }

    function moveToTop() {
        if (root.unreadCount == 0) {
            view.positionViewAtBeginning()
        } else {
            view.positionViewAtIndex(root.unreadCount - 1, ListView.Beginning)
        }
    }

    property bool loadedUntilLastPos: false
    function updateLoadedUntilLastPos() {
        var loadedUntilLastPos = true
        for (var i = 0; i < model.childObjects.length; i++) {
            if (!model.childObjects[i].streaming && model.childObjects[i].loadingUntilLastPos) {
                loadedUntilLastPos = false
                break
            }
        }
        root.loadedUntilLastPos = loadedUntilLastPos
    }

    Timer {
        id: positionViewAtBeginning
        running: root.loadedUntilLastPos
        repeat: false
        interval: 500
        onTriggered: {
            view.positionViewAtBeginning()
            for (var i = 0; i < model.childObjects.length; i++) {
                if (!model.childObjects[i].streaming)
                    model.childObjects[i].loadUntilLatest()
            }
        }
    }

    StateGroup {
        states: [
            State {
                name: 'fake visible'
//                when: root.parent.visible && !root.loadedUntilLastPos
                PropertyChanges {
                    target: root
                    visible: true
                    opacity: 1.0
                }
            },
            State {
                name: "page stack is available"
                when: typeof pageStack === 'object'
                PropertyChanges {
                    target: refresh
                    running: refresh.toBeRefreshed && platformWindow.visible && !homeTimeline.loading && pageStack.depth == 1
                }
            }
        ]
    }

    property string created_at

    StateGroup {
        states: [
            State {
                name: "show time"
                when: view.moving && topData.created_at
                PropertyChanges {
                    target: root
                    created_at: topData.created_at
                    title: Qt.formatDateTime(new Date(root.created_at), constants.dateTimeFormat)
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    StatusListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        loading: model.loading
        active: (root.active && !homeTimeline.loading) || !root.loadedUntilLastPos
        model: UnionModel {
            id: model
            UserStreamModel {
                id: userStream
                enabled: !(homeTimeline.loading && homeTimeline.pushOrder != HomeTimelineModel.PushOlderToNewer) && !positionViewAtBeginning.running && test.online && constants.streaming && !(constants.streamingOnlyWifi && !window.wlanConnected)
                onFollowedBy: infoBanners.followedBy(status)
                onFavorited: infoBanners.favorited(status)
                onFiltering: {
                    if (value.user.id_str !== oauth.user_id && window.friends.length > 0 && window.friends.indexOf(value.user.id_str) < 0) userStream.filter()
                    if (window.filter(value)) userStream.filter()
                }
                onFriendsChanged: window.friends = friends
            }
            HomeTimelineModel {
                id: homeTimeline
                count: 50
                pushOrder: HomeTimelineModel.PushAtOnce
                sortKey: 'id_str'
                max_id: constants.restoringLastPositionDisabled ? '' : root.__maxReadIdStr
                onFiltering: if (window.filter(value)) homeTimeline.filter()
                property bool loadingUntilLastPos: true
                property bool loadingUntilLatest: false
                property int lastSize: 0

                function loadUntilLatest() {
                    homeTimeline.pushOrder = HomeTimelineModel.PushOlderToNewer
                    loadingUntilLatest = true
                    lastSize = size
                    since_id = size > 0 ? model.get(0).id_str : ''
                    max_id = ''
                    count = 200
                    view.contentY++
                    reload()
                }

                onLoadingChanged: {
                    if (loading) {
                        console.debug('loading:', max_id, since_id, size, lastSize)
                    } else {
                        console.debug('loaded:', max_id, since_id, size, lastSize)
                        if (loadingUntilLastPos) {
                            loadingUntilLastPos = false
                            root.updateLoadedUntilLastPos()
                        } else if (loadingUntilLatest) {
                            if (lastSize == size) {
                                view.contentY--
                                loadingUntilLatest = false
                            } else {
                                lastSize = size
                                //page++
                                reload()
                            }
                        }
                    }
                }

                onRateLimitExceeded: {
                    infoBanners.rateLimitMessage(xrlLimit, xrlRemaining, xrlReset)
                }
            }

            onSizeChanged: refresh.toBeRefreshed = true
        }
        onTopItemIndexChanged: refresh.toBeRefreshed = true

        onReload: {
            if (test.online) {
                if (!homeTimeline.loading) {
                    homeTimeline.loadUntilLatest()
                }

                if (!userStream.loading) {
                    userStream.reload()
                }
            } else {
                test.exec()
            }
        }
        onMore: {
            if (!homeTimeline.loading) {
                homeTimeline.pushOrder = HomeTimelineModel.PushNewerToOlder
                homeTimeline.max_id = homeTimeline.size == 0 ? '' : homeTimeline.get(homeTimeline.size - 1).id_str
                homeTimeline.count = 50
                homeTimeline.since_id = ''
                homeTimeline.reload()
            }
        }

        onShowDetail: if (state != 'loading') pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: {
            if (state != 'loading') {
                root.openLink(link)
            }
        }

        states: [
            State {
                name: 'loading'
                when: homeTimeline.loading || positionViewAtBeginning.running
                PropertyChanges {
                    target: view
                    interactive: false
                    opacity: 0.5
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { properties: 'opacity' }
            }
        ]
    }

    Timer {
        running: (window.timerUpdateForcedOnWifi || !constants.streaming) && interval > 0 && test.online
        interval: constants.updateInterval * 60 * 1000
        repeat: true
        onTriggered: {
            for (var i = 0; i < model.childObjects.length; i++) {
                if (!model.childObjects[i].streaming)
                    model.childObjects[i].loadUntilLatest()
            }
        }
    }

    Connections {
        target: oauth
        onStateChanged: {
            if (oauth.state === OAuth.Unauthorized) {
                settings.saveData('HomePage/maxReadIdStr', '')
            }
        }
    }

    Component.onDestruction: {
        if (oauth.state === OAuth.Authorized) {
            settings.saveData('HomePage/maxReadIdStr', root.__maxReadIdStr)
        }
    }

    Connections {
        target: test
        onOnlineChanged: {
            if (test.online) {
                if (!homeTimeline.loading) {
                    homeTimeline.loadUntilLatest()
                }
            }
        }
    }
}
