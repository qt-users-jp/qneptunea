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
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'
import '../Utils/TweetCounter.js' as TweetCounter


AbstractLinkPage {
    id: root

    title: qsTr('Tweet')
    busy: status.loading
    visualParent: container

    property bool skipAfterTweeting: true

    Status {
        id: status
        onLoadingChanged: {
            if (loading) return
            if (id_str.length > 0 && root.status === PageStatus.Active) {
                var entities = status.entities
                if (defined(entities.hashtags.length)) {
                    for (var j = 0; j < entities.hashtags.length; j++) {
                        hashTagsModel.add(entities.hashtags[j].text)
                    }
                }
                if (defined(entities.user_mentions.length)) {
                    for (var j = 0; j < entities.user_mentions.length; j++) {
                        screenNamesModel.add(entities.user_mentions[j].screen_name)
                    }
                }

                var found = pageStack.find( function(page) {
                                               return !(typeof page.skipAfterTweeting === 'boolean' && page.skipAfterTweeting)
                                           })
                if (found) {
                    pageStack.pop(found)
                } else {
                    pageStack.pop()
                }
            }
        }
    }

    property string statusText
    property variant in_reply_to
    property bool retweet: defined(root.in_reply_to) && defined(root.in_reply_to.id_str) && root.in_reply_to.text.length > 0 && root.statusText == ''
    property bool reply: defined(root.in_reply_to) && defined(root.in_reply_to.id_str) && textArea.text.indexOf('@' + root.in_reply_to.user.screen_name) !== -1
    property bool first: true

    property string currentAction
    property variant media: []
    property variant location

    onStatusChanged: {
        switch(root.status) {
        case PageStatus.Active:
            if (currentAction == '' && !root.retweet) {
                textArea.forceActiveFocus()
            }
            break
        case PageStatus.Activating: {
            switch (currentAction) {
            case '': {
                textArea.text = root.statusText == '' && defined(root.in_reply_to) ? root.in_reply_to.text.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&') : root.statusText
                root.retweet = defined(root.in_reply_to) && defined(root.in_reply_to.id_str) && root.in_reply_to.text.length > 0 && root.statusText == ''
                break }
            case 'gallery':
                if (defined(mediaSelected)) {
                    var media = root.media
                    media.push(mediaSelected)
                    mediaSelected = undefined
                    while (media.length > Math.max(1, configuration.max_media_per_upload))
                        media.shift()
                    root.media = media
                }
                break
            case 'location':
                root.location = locationSelected
                break
            }
            root.currentAction = ''
            break
        }
        case PageStatus.Inactive:
            if (root.currentAction === '') {
                root.statusText = ''
                root.in_reply_to = undefined
                root.first = true
                root.media = []
                root.location = undefined
                textArea.text = ''
            }
            break
        default:
            break
        }
    }

    StateGroup {
        states: [
            State {
                name: "retweet"
                when: root.retweet
                PropertyChanges {
                    target: root
                    title: qsTr('Retweet')
                }
            },
            State {
                name: "reply"
                when: root.reply
                PropertyChanges {
                    target: root
                    title: qsTr('Reply')
                }
            }
        ]
    }

    Flickable {
        id: container
        anchors.top: parent.top
        anchors.topMargin: root.headerHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: completion.top

        clip: true
        contentHeight: contents.height
        interactive: !defined(root.linkMenu)

        Column {
            id: contents
            width: parent.width
            spacing: constants.listViewMargins

            StatusDelegate {
                id: in_reply_to
                width: parent.width
                visible: false
                states: [
                    State {
                        when: defined(root.in_reply_to)
                        PropertyChanges {
                            target: in_reply_to
                            item: root.in_reply_to
                            visible: !root.retweet
                        }
                    }
                ]
            }

            Item {
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewScrollbarWidth
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewScrollbarWidth
                height: detailArea.height + 12
                z: 1

                ProfileImage {
                    id: icon
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    source: 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=%2'.arg(root.retweet ? root.in_reply_to.user.screen_name : verifyCredentials.screen_name).arg(constants.listViewIconSizeName)
                    _id: root.retweet ? root.in_reply_to.user.profile_image_url : verifyCredentials.profile_image_url
                    width: constants.listViewIconSize
                    height: width
                }

                CountBubble {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    anchors.horizontalCenter: icon.horizontalCenter
                    anchors.horizontalCenterOffset: constants.listViewMargins / 2
                    value: textArea.counter
                    largeSized: true
                    visible: !root.retweet
                }

                Column {
                    id: detailArea
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: icon.right
                    anchors.leftMargin: constants.listViewMargins
                    anchors.right: parent.right
                    spacing: constants.listViewMargins
                    z: 1

                    Row {
                        id: nameArea
                        spacing: constants.listViewMargins
                        Text {
                            text: root.retweet ? root.in_reply_to.user.name : verifyCredentials.name
                            textFormat: Text.PlainText
                            font.bold: true
                            font.family: constants.fontFamily
                            font.pixelSize: constants.fontSmall
                            color: constants.nameColor
                        }
                        Text {
                            text: '@%1'.arg(root.retweet ? root.in_reply_to.user.screen_name : oauth.screen_name)
                            font.family: constants.fontFamily
                            font.pixelSize: constants.fontSmall
                            color: constants.nameColor
                        }
                    }

                    Item {
                        width: parent.width
                        height: textArea.height
                        TextArea {
                            id: textArea
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: tweetLandscape.left
                            textFormat: TextEdit.PlainText
                            wrapMode: TextEdit.WordWrap
                            enabled: !status.loading && !currentPluginLoading
                            platformStyle: TextAreaStyle { textFont.pixelSize: constants.fontDefault }

                            property string preedit: text.substring(0, textArea.cursorPosition) + textArea.platformPreedit + textArea.text.substring(textArea.cursorPosition)
                            property int counter: TweetCounter.count(textArea.preedit, 140 - root.media.length * configuration.characters_reserved_per_media, configuration.short_url_length, configuration.short_url_length_https)

                            property string text2: text
                            onTextChanged: text2 = text
                            onText2Changed: updateCompletion()
                            onCursorPositionChanged: updateCompletion()
                            onPreeditChanged: updateCompletion()
                            function updateCompletion() {
                                if (text2.length == cursorPosition || text2.charAt(cursorPosition) == ' ' || text2.charAt(cursorPosition) == '\n') {
                                    var screenName = new RegExp(/(@[a-zA-z0-9_]*)$/)
                                    var left = text2.substring(0, cursorPosition).concat(platformPreedit)
                                    if (screenName.test(left)) {
                                        screenNamesView.filter = RegExp.$1
                                    } else {
                                        screenNamesView.filter = ''
                                    }

                                    var hashTag = new RegExp(/(#[^ \.]*)$/)
                                    if (hashTag.test(left)) {
                                        hashTagsView.filter = RegExp.$1
                                    } else {
                                        hashTagsView.filter = ''
                                    }
                                } else {
                                    screenNamesView.filter = ''
                                    hashTagsView.filter = ''
                                }
                            }

                            Connections {
                                target: textArea
                                onActiveFocusChanged: {
                                    if (first) {
                                        first = false
                                        if (root.retweet) {
                                            textArea.text = ' RT @%1: %2'.arg(root.in_reply_to.user.screen_name).arg(textArea.text)
                                            textArea.cursorPosition = 0
                                            root.retweet = false
                                        } else {
                                            textArea.cursorPosition = textArea.text.length
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            id: tweetLandscape
                            width: visible ? 322 / 2 : 0
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            text: tweet.text
                            enabled: tweet.enabled
                            checked: textArea.counter >= 0
                            visible: !window.inPortrait && !retweet
                            onClicked: tweet.tweet()
                            Behavior on width { NumberAnimation{} }
                        }
                    }

                    RetweetedBy {
                        visible: root.retweet
                        user: verifyCredentials
                    }
                }
            }
            Separator {
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewScrollbarWidth
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewScrollbarWidth
                color: constants.separatorFromMeColor
            }
            Flow {
                visible: !root.retweet
                width: parent.width
                Repeater {
                    model: root.media
                    delegate: RectButton {
                        id: thumbnail
                        height: 240
                        width: 240
                        icon: model.modelData
                        fill: true
                        enabled: !status.loading && !currentPluginLoading
                        onClicked: {
                            var media = []
                            for (var i = 0; i < root.media.length; i++) {
                                if (root.media[i] !== thumbnail.icon) {
                                    media.push(root.media[i])
                                }
                            }
                            root.media = media
                        }
                    }
                }
                RectButton {
                    width: 240
                    height: 240
                    visible: root.media.length < configuration.max_media_per_upload
                    icon: 'image://theme/icon-m-toolbar-gallery'.concat(theme.inverted ? "-white" : "")
                    enabled: !status.loading && !currentPluginLoading
                    onClicked: {
                        root.currentAction = 'gallery'
                        mediaSelected = undefined
                        pageStack.push(selectMediaPage)
                    }
                }
                RectButton {
                    width: 240
                    height: 240
                    visible: !defined(root.location)
                    icon: 'image://theme/icon-m-common-location'.concat(theme.inverted ? "-inverse" : "")
                    enabled: !status.loading && !currentPluginLoading
                    onClicked: {
                        root.currentAction = 'location'
                        locationSelected = undefined
                        pageStack.push(selectLocationPage)
                    }
                }
                RectButton {
                    id: map
                    width: 240
                    height: 240
                    visible: defined(root.location)
                    property double _lat: visible ? root.location.latitude : 0
                    property double _long: visible ? root.location.longitude : 0
                    icon: visible ? "http://maps.google.com/staticmap?zoom=17&center=%1,%2&size=%3x%4".arg(_lat).arg(_long).arg(width).arg(height) : ''
                    fill: true
                    enabled: !status.loading && !currentPluginLoading
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
                    onClicked: {
                        root.location = undefined
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: container }

    Column {
        id: completion
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.footerHeight

        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        CompletionView {
            id: screenNamesView
            width: parent.width
            height: Math.max(constants.fontDefault, 48) * 1.2

            model: screenNamesModel
            icon: true
            z: 1
            opacity: filter.length > 0 ? 1.0 : 0.0
            onClicked: {
                var screenName = new RegExp(/(@[a-zA-z0-9_]*)$/)
                if (screenName.test(textArea.text2.substring(0, textArea.cursorPosition))) {
                    var len = RegExp.$1.length
                    var left = textArea.text2.substring(0, textArea.cursorPosition)
                    var center = candidate.substring(len - 1)
                    if (left.length === len)
                        center = center.concat(' ')
                    var right = textArea.text2.substring(textArea.cursorPosition)
    //                                    textArea.preedit = ''
                    textArea.text = left.concat(center).concat(right)
                    textArea.forceActiveFocus()
                    textArea.cursorPosition = left.length + center.length
                    textArea.platformPreedit = ''
                }
                screenNamesView.filter = ''
            }
        }
        CompletionView {
            id: hashTagsView
            width: parent.width
            height: Math.max(constants.fontDefault, 48) * 1.2

            model: hashTagsModel
            z: 1
            opacity: filter.length > 0 ? 1.0 : 0.0
            onClicked: {
                var hashTag = new RegExp(/(#[^ \.]*)$/)
                if (hashTag.test(textArea.text2.substring(0, textArea.cursorPosition))) {
                    var len = RegExp.$1.length
                    var left = textArea.text2.substring(0, textArea.cursorPosition)
                    var center = candidate.substring(len - 1)
                    if (left.length === len)
                        center = center.concat(' ')
                    var right = textArea.text2.substring(textArea.cursorPosition)
                    textArea.text = left.concat(center).concat(right)
                    textArea.forceActiveFocus()
                    textArea.cursorPosition = left.length + center.length
                    textArea.platformPreedit = ''
                }
                hashTagsView.filter = ''
            }
        }
    }
    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            id: menuLayout
            Repeater {
                model: tweetPlugins.pluginInfo
                delegate: MenuItemWithIcon {
                    id: customItem
                    iconSource: model.plugin.icon
                    text: model.plugin.name
                    visible: model.plugin.visible
                    enabled: model.plugin.enabled
                    Binding { target: model.plugin; property: 'text'; value: textArea.text }
                    Binding { target: model.plugin; property: 'media'; value: root.media }
                    Binding { target: model.plugin; property: 'location'; value: root.location }
                    Connections {
                        target: model.plugin
                        onTextChanged: textArea.text = model.plugin.text
                        onMediaChanged: root.media = model.plugin.media
                        onLocationChanged: root.location = model.plugin.location
                        onLoadingChanged: {
                            if (loading) {
                                root.currentPlugin = model.plugin
                            }
                        }
                    }

                    onClicked: {
                        root.currentPlugin = plugin
                        model.plugin.exec()
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
        ToolButtonRow {
            ToolButton {
                id: tweet

                visible: !tweetLandscape.visible
                enabled: textArea.text.length > 0 || (!status.loading && !currentPluginLoading)
                checked: textArea.counter >= 0
                text: qsTr('Tweet')
                function tweet() {
                    var parameters = {'status': textArea.text, 'media': root.media}
                    if (root.retweet)
                        status.retweetStatus({'id': root.in_reply_to.id_str})
                    else {
                        if (root.reply)
                            parameters['in_reply_to_status_id'] = root.in_reply_to.id_str
                        if (defined(root.location)) {
                            parameters['_lat'] = root.location.latitude
                            parameters['_long'] = root.location.longitude
                        }
                        status.updateStatus(parameters)
                    }
                }
                onClicked: tweet.tweet()
                states: [
                    State {
                        name: "retweet"
                        when: root.retweet
                        PropertyChanges {
                            target: tweet
                            text: qsTr('Retweet')
                        }
                    }
                ]
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            opacity: enabled ? 1.0 : 0.5
            enabled: !status.loading && !currentPluginLoading && !root.retweet
            onClicked: {
                if (menu.status == DialogStatus.Closed)
                    menu.open()
                else
                    menu.close()
            }
        }
        onClosing: menu.close()
    }

    StateGroup {
        states: [
            State {
                name: "hidden"
                when: tweetLandscape.visible && textArea.activeFocus
                PropertyChanges {
                    target: root
                    footerOpacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { properties: 'footerOpacity, height' }
            }
        ]
    }

    StringListModel { id: screenNamesModel; key: 'TweetPage/ScreenName' }
    StringListModel { id: hashTagsModel; key: 'TweetPage/HashTag' }
}
