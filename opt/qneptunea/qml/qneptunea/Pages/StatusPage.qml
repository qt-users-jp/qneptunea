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
import QNeptunea 1.0
import '../Delegates'
import '../QNeptunea/Components/'

AbstractLinkPage {
    id: root

    title: qsTr('Conversation')
    busy: status.loading || relatedResults.loading || delegate.loading || conversationStatus.loading || conversationTimer.running || adjustTimer.running || activitySummary.loading
    visualParent: flickable

    property variant thumbnails: []
    property bool skipAfterTweeting: true

    QueryDialog {
        id: destroyStatus
        icon: 'image://theme/icon-m-content-file-unknown'.concat(theme.inverted ? "-inverse" : "")
        titleText: qsTr('Delete Tweet')
        message: qsTr('Are you sure you want to delete this Tweet?')

        acceptButtonText: qsTr('Delete')
        rejectButtonText: qsTr('Cancel')

        onAccepted: status.destroyStatus()
    }

    Status {
        id: status
        id_str: root.id_str
        onIdStrChanged: {
            if (id_str.length == 0 && root.status === PageStatus.Active)
                pageStack.pop()
        }
    }

    ListModel { id: mediaList }

    Timer {
        running: !status.loading
        repeat: false
        interval: 100
        property bool done: false
        onTriggered: {
            if (done) return

            var rich_text = root.__status.rich_text
            var href = new RegExp(/<a class="link" href="(https?:\/\/.+?)"/g);
            var arr;
            while ((arr = href.exec(rich_text)) !== null) {
                var url = arr[1]
                var component = Qt.createComponent('../QNeptunea/Components/Thumbnailer.qml')
                if (component.status === Component.Ready) {
                    component.createObject(thumbnails, {'url': url, 'width': 240, 'height': 240})
                } else {
                    console.debug(component.status, component.errorString())
                }
            }

            var media = root.__status.media
            for (var i = 0; i < media.length; i++) {
                var component = Qt.createComponent('../QNeptunea/Components/Thumbnailer.qml')
                if (component.status == Component.Ready) {
                    console.debug(media[i])
                    component.createObject(thumbnails, {'url': media[i], 'width': 240, 'height': 240})
                }
            }
            done = true
        }
    }

    ActivitySummary {
        id: activitySummary
//        _id: root.__status.id_str
    }

    Timer {
        running: true
        repeat: false
        interval: 250
        onTriggered: activitySummary._id = root.__status.id_str
    }

    property bool __retweeted: defined(status.retweeted_status.id_str)
    property variant __status: __retweeted ? status.retweeted_status : status
    property variant __user: __status.user

    RelatedResultsModel {
        id: relatedResults
        _id: status.retweeted_status.id_str ? status.retweeted_status.id_str : status.id_str
        sortKey: 'id_str'
        property bool done: false
        onLoadingChanged: {
            if (!loading) {
                for (var i = 0; i < relatedResults.size; i++) {
                    var tweet = relatedResults.get(i)
                    if (root.__status.id_str.length < tweet.id_str.length || (root.__status.id_str.length == tweet.id_str.length && root.__status.id_str < tweet.id_str))
                        replies.append(tweet)
                    else {
                        var found = false
                        for (var j = 0; j < conversationModel.count; j++) {
                            if (conversationModel.get(j).id_str === tweet.id_str) {
                                found = true
                                break
                            }
                        }
                        if (!found)
                            conversationModel.append(tweet)
                    }
                }
                done = true
            }
        }
    }

    Status {
        id: conversationStatus
    }

    StateGroup {
        states: [
            State {
                name: "read more"
                when: relatedResults.done && !conversationStatus.loading && !conversationTimer.running
                StateChangeScript {
                    script: {
                        conversationTimer.start()
                    }
                }
            }
        ]
    }

    Timer {
        id: conversationTimer
        repeat: false
        interval: 50
        onTriggered: {
            var in_reply_to_status_id_str = root.__status.in_reply_to_status_id_str
            if (!defined(in_reply_to_status_id_str) || in_reply_to_status_id_str.length === 0) {
                adjustTimer.start()
                return;
            }
            if (conversationStatus.id_str.length > 0) {
                conversationModel.append(conversationStatus.data)
            }

            if (conversationModel.count == 0) {
                conversationStatus.id_str = in_reply_to_status_id_str
            } else {
                in_reply_to_status_id_str = conversationModel.get(conversationModel.count - 1).in_reply_to_status_id_str

                if (defined(in_reply_to_status_id_str) && in_reply_to_status_id_str.length > 0){
                    conversationStatus.id_str = in_reply_to_status_id_str
                } else {
                    adjustTimer.start()
                }
            }
        }
    }

    Timer {
        id: adjustTimer
        repeat: false
        interval: 100
        onTriggered: {
            flickable.contentY = delegate.y + 1
            flickable.visible = true
            flickable.contentY = delegate.y
        }
    }

    StatusDetailDelegate {
        anchors.top: parent.top; anchors.topMargin: root.headerHeight
        width: parent.width
        temporary: true
        item: status.data
        user: status.data.user
        visible: !flickable.visible
        onLinkActivated: openLink(link, status.data)
    }

    Flickable {
        id: flickable
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentWidth: width
        contentHeight: detail.height
        clip: true
        contentY: delegate.y
        visible: false
        interactive: !defined(root.linkMenu)

        Column {
            id: detail
            width: parent.width

            Repeater {
                model: ListModel {
                    id: replies
                }
                delegate: StatusDelegate {
                    width: detail.width
                    item: model
                    onClicked: pageStack.push(statusPage, {'id_str': model.id_str})
                    onLinkActivated: openLink(link)
                }
            }

            StatusDetailDelegate {
                id: delegate
                width: parent.width
                item: status.data
                user: status.data.user
                onLinkActivated: openLink(link, status.data)
                onUserClicked: pageStack.push(userPage, {'id_str': user.id_str})
            }

            Flow {
                id: thumbnails
                width: parent.width
                function openLink(link) {
                    root.openLink(link)
                }
            }

            Row {
                width: parent.width
                SpinnerImage {
                    id: map
                    property double _lat: visible && root.__status.geo.coordinates[0] ? root.__status.geo.coordinates[0] : 0.0
                    property double _long: visible && root.__status.geo.coordinates[1] ? root.__status.geo.coordinates[1] : 0.0
                    source: "http://maps.google.com/staticmap?zoom=15&center=%1,%2&size=240x240&markers=%1,%2,red,a&saturation=-100".arg(_lat).arg(_long)
                    width: 240
                    height: 240
                    visible: defined(root.__status.geo) && defined(root.__status.geo.coordinates)
                    Item {
                        anchors.centerIn: parent
                        height: pin.height * 2
                        Image {
                            id: pin
                            source: 'http://maps.gstatic.com/mapfiles/markers2/marker.png'
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(mapPage, {'_lat': map._lat, '_long': map._long})
                    }
                }
                Column {
                    width: parent.width - map.width
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: visible ? '<a style="%1">%2</a>'.arg(constants.placeStyle).arg(root.__status.place.full_name) : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontLarge
                        visible: defined(root.__status.place) && defined(root.__status.place.full_name)
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: visible ? '<a style="%1">%2</a>'.arg(constants.placeStyle).arg(root.__status.place.country) : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontLarge
                        visible: defined(root.__status.place) && defined(root.__status.place.country)
                    }
                }
            }

            UserIcons {
                width: parent.width
                visible: activitySummary.favoriters.length > 0
                icon: 'image://theme/icon-m-toolbar-favorite-mark'.concat(theme.inverted ? "-white" : "")
                model: activitySummary.favoriters
            }

            UserIcons {
                width: parent.width
                visible: activitySummary.retweeters.length > 0
                icon: '../images/retweet'.concat(theme.inverted ? "-white.png" : '.png')
                model: activitySummary.retweeters
            }

            Repeater {
                model: ListModel {
                    id: conversationModel
                }
                delegate: StatusDelegate {
                    width: detail.width
                    item: model
                    onClicked: pageStack.push(statusPage, {'id_str': model.id_str})
                    onLinkActivated: openLink(link)
                }
            }
        }
    }

    ScrollBar {
        target: flickable
        height: flickable.contentY / 10
    }

    Menu {
        id: menu
        visualParent: flickable
        MenuLayout {
            id: menuLayout
            MenuItemWithIcon {
                property bool muted: window.filters.indexOf('@%1'.arg(root.__user.screen_name)) > -1
                iconSource: 'image://theme/icon-m-toolbar-volume'.concat(muted ? '' : '-off').concat(theme.inverted ? "-white" : "")
                text: muted ? qsTr('Unmute @%1').arg(root.__user.screen_name) : qsTr('Mute @%1').arg(root.__user.screen_name)
                onClicked: {
                    var filters = window.filters
                    if (muted) {
                        var index = filters.indexOf('@%1'.arg(root.__user.screen_name))
                        while (index > -1) {
                            filters.splice(index, 1)
                            index = filters.indexOf('@%1'.arg(root.__user.screen_name))
                        }
                    } else {
                        filters.unshift('@%1'.arg(root.__user.screen_name))
                    }
                    window.filters = filters
                }
            }
            Repeater {
                model: servicePlugins.pluginInfo
                delegate: MenuItemWithIcon {
                    id: customItem
                    iconSource: model.plugin.icon
                    text: model.plugin.service
                    property url link: 'http://twitter.com/%1/status/%2'.arg(__status.user.screen_name).arg(__status.id_str)
                    visible: model.plugin.matches(customItem.link)
                    onClicked: {
                        root.currentPlugin = plugin
                        model.plugin.open(customItem.link, __status, delegate)
                    }
                }
            }
        }
    }
    Connections {
        target: menu
        onStatusChanged: root.linkMenu = (menu.status === DialogStatus.Closed ? undefined : menu)
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-reply"
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                var entities = status.entities
                var statusText = '@'.concat(__user.screen_name).concat(' ')
                if (defined(entities.user_mentions.length)) {
                    for (var j = 0; j < entities.user_mentions.length; j++) {
                        var id_str = entities.user_mentions[j].id_str
                        if (id_str !== __user.id_str && id_str !== oauth.user_id) {
                            statusText = statusText.concat('@%1 '.arg(entities.user_mentions[j].screen_name))
                        }
                    }
                }
                if (defined(entities.hashtags.length)) {
                    for (var j = 0; j < entities.hashtags.length; j++) {
                        statusText = statusText.concat(' #%1'.arg(entities.hashtags[j].text))
                    }
                }
                pageStack.push(tweetPage, {'statusText': statusText, 'in_reply_to': __status})
            }
        }

        ToolIcon {
            iconSource: '../images/retweet'.concat(theme.inverted ? '-white.png' : '.png')
            enabled: !root.__status.retweeted && (root.__retweeted ? true : !root.__user.protected)
            visible: status.user.id_str !== oauth.user_id
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                if (__status.user.id_str == oauth.user_id || __status.retweeted) {
                    pageStack.push(tweetPage, {'statusText': ' RT @%1: %2'.arg(__status.user.screen_name).arg(__status.text.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')), 'in_reply_to': __status})
                } else {
                    pageStack.push(tweetPage, {'in_reply_to': __status})
                }
            }
        }

        ToolIcon {
            iconSource: 'image://theme/icon-m-toolbar-delete'.concat(theme.inverted ? "-white" : "")
            visible: status.user.id_str === oauth.user_id
            onClicked: destroyStatus.open()
        }


        ToolIcon {
            id: favorite
            iconSource: 'image://theme/icon-m-toolbar-favorite-unmark'.concat(theme.inverted ? "-white" : "")
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                if (status.favorited)
                    status.unfavorite()
                else
                    status.favorite()
            }

            states: [
                State {
                    name: "favorited"
                    when: status.favorited
                    PropertyChanges {
                        target: favorite
                        iconSource: 'image://theme/icon-m-toolbar-favorite-mark'.concat(theme.inverted ? "-white" : "")
                    }
                }
            ]
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                if (root.linkMenu) {
                    root.linkMenu.close()
                } else {
                    if (menu.status == DialogStatus.Closed)
                        menu.open()
                    else
                        menu.close()
                }
            }
        }
        onClosing: {
            if (root.linkMenu) root.linkMenu.close()
            menu.close()
        }
    }
}
