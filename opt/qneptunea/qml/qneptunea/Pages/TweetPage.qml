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
                if (typeof entities.hashtags.length !== 'undefined') {
                    for (var j = 0; j < entities.hashtags.length; j++) {
                        console.debug(entities.hashtags[j].text)
                        hashTagsModel.add(entities.hashtags[j].text)
                    }
                }
                if (typeof entities.user_mentions.length !== 'undefined') {
                    for (var j = 0; j < entities.user_mentions.length; j++) {
                        console.debug(entities.user_mentions[j].id_str, entities.user_mentions[j].screen_name)
                        screenNamesModel.add(entities.user_mentions[j].screen_name)
                    }
                }

                var found = pageStack.find( function(page) {
                                               return !(typeof page.skipAfterTweeting === 'boolean' && page.skipAfterTweeting)
                                           })
                if (found) {
//                    console.debug(found)
                    pageStack.pop(found)
                } else {
//                    console.debug('not found')
                    pageStack.pop()
                }
            }
        }
    }

    property bool modified: false
    property string statusText
    property variant in_reply_to
    property bool retweet: typeof root.in_reply_to !== 'undefined' && typeof root.in_reply_to.id_str !== 'undefined' && root.in_reply_to.text.length > 0 && root.statusText == ''
    property bool reply: typeof root.in_reply_to !== 'undefined' && typeof root.in_reply_to.id_str !== 'undefined' && textArea.text.indexOf('@' + root.in_reply_to.user.screen_name) !== -1
    property bool first: true

    property string currentAction
    property alias text: textArea.text
    property variant media: []
    property variant location

    onStatusChanged: {
        if (root.status === PageStatus.Active) {
            if (currentAction == '') {
                if (!root.retweet) {
                    textArea.forceActiveFocus()
                }
            } else if (root.currentAction == 'gallery') {
                if (mediaSelected !== undefined) {
                    var media = root.media
                    media.push(mediaSelected)
                    mediaSelected = undefined
                    while (media.length > Math.max(1, configuration.max_media_per_upload))
                        media.shift()
                    root.media = media
                }
                root.currentAction = ''
            } else if (root.currentAction == 'location') {
                root.location = locationSelected
                root.currentAction = ''
            }
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
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        clip: true
        contentHeight: contents.height
        interactive: typeof root.linkMenu === 'undefined'

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
                        when: typeof root.in_reply_to !== 'undefined'
                        PropertyChanges {
                            target: in_reply_to
                            item: root.in_reply_to
                            user: root.in_reply_to.user
                            visible: !root.retweet
                        }
                    }
                ]
            }

            Item {
                width: parent.width
                height: detailArea.height + 12
                z: 1

                ProfileImage {
                    id: icon
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    source: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(root.retweet ? root.in_reply_to.user.screen_name : verifyCredentials.screen_name).concat('&size=').concat(constants.listViewIconSizeName)
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
                            text: '@' + (root.retweet ? root.in_reply_to.user.screen_name : oauth.screen_name)
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
                            text: root.statusText == '' && typeof root.in_reply_to !== 'undefined' ? root.in_reply_to.text.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&') : root.statusText
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
                                            textArea.text = ' RT @' + root.in_reply_to.user.screen_name + ': ' + textArea.text
                                            textArea.cursorPosition = 0
                                            root.retweet = false
                                        } else {
                                            textArea.cursorPosition = textArea.text.length
                                        }
                                    }
                                }
                            }
                        }

                        CompletionView {
                            id: screenNamesView
                            anchors.top: textArea.bottom
                            anchors.left: textArea.left
                            anchors.leftMargin: 15
                            anchors.right: textArea.right
                            anchors.rightMargin: 15
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
                            anchors.top: textArea.bottom
                            anchors.left: textArea.left
                            anchors.leftMargin: 15
                            anchors.right: textArea.right
                            anchors.rightMargin: 15
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
            Rectangle {
                width: parent.width
                height: constants.separatorHeight
                color: constants.separatorFromMeColor
                opacity: constants.separatorOpacity
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
                                if (root.media[i] != thumbnail.icon) {
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
                    visible: typeof root.location === 'undefined'
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
                    visible: typeof root.location !== 'undefined'
                    property double _lat: visible ? root.location.latitude : 0
                    property double _long: visible ? root.location.longitude : 0
                    icon: visible ? "http://maps.google.com/staticmap?zoom=17&center=" + _lat + "," + _long + "&size=" + width + "x" + height : ''
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
        onStatusChanged: root.linkMenu = (menu.status == DialogStatus.Closed ? undefined : menu)
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
                        if (typeof root.location !== 'undefined') {
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
