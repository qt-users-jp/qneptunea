import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import QNeptunea 1.0
import '../Views'
import '../Delegates'
import '../QNeptunea/Components/'

AbstractLinkPage {
    id: root

    title: qsTr('Conversation')
    busy: status.loading || relatedResults.loading || delegate.loading || conversationStatus.loading || conversationTimer.running || adjustTimer.running || activitySummary.loading
    visualParent: flickable

    property variant thumbnails: []
    property bool skipAfterTweeting: true

    Status {
        id: status
        id_str: root.id_str
        onIdStrChanged: {
            if (id_str.length == 0 && root.status == PageStatus.Active)
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
            var href = new RegExp(/<a class="link" href="(http:\/\/.+?)"/g);
            var arr;
            while ((arr = href.exec(rich_text)) !== null) {
                var url = arr[1]
                console.debug(url)
                var component = Qt.createComponent('../QNeptunea/Components/Thumbnailer.qml')
                if (component.status === Component.Ready) {
                    component.createObject(thumbnails, {'url': url, 'width': 240, 'height': 240})
                } else {
                    console.debug(component.status, component.errorString())
                }
            }

            var media = root.__status.media
            console.debug('media.length', media.length)
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

    property bool __retweeted: typeof status.retweeted_status.id_str !== 'undefined'
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
//        onIdStrChanged: console.debug('conversationStatus.id_str =', id_str)
//        onLoadingChanged: console.debug('conversationStatus.loading =', loading)
    }

    StateGroup {
        states: [
            State {
                name: "read more"
                when: relatedResults.done && !conversationStatus.loading && !conversationTimer.running
                StateChangeScript {
                    script: {
//                        console.debug('conversationTimer.start()', conversationTimer.running)
                        conversationTimer.start()
                    }
                }
            }
        ]
//        onStateChanged: console.debug('state', state)
    }

    Timer {
        id: conversationTimer
        repeat: false
        interval: 50
        onTriggered: {
//            console.debug('root.__status.in_reply_to_status_id_str.length', root.__status.in_reply_to_status_id_str.length)
            var in_reply_to_status_id_str = root.__status.in_reply_to_status_id_str
            if (typeof in_reply_to_status_id_str === 'undefined' || in_reply_to_status_id_str.length === 0) {
                adjustTimer.start()
                return;
            }
//            console.debug('conversationStatus.id_str.length', conversationStatus.id_str.length)
            if (conversationStatus.id_str.length > 0) {
//                console.debug(conversationStatus.plain_text)
                conversationModel.append(conversationStatus.data)
            }

//            console.debug('conversationModel.count', conversationModel.count)
            if (conversationModel.count == 0) {
//                console.debug('root.__status.in_reply_to_status_id_str', root.__status.in_reply_to_status_id_str)
                conversationStatus.id_str = in_reply_to_status_id_str
            } else {
                in_reply_to_status_id_str = conversationModel.get(conversationModel.count - 1).in_reply_to_status_id_str
//                console.debug('typeof in_reply_to_status_id_str', typeof in_reply_to_status_id_str)

                if (typeof in_reply_to_status_id_str !== 'undefined' && in_reply_to_status_id_str.length > 0){
//                    console.debug('conversationModel.get(conversationModel.count - 1).in_reply_to_status_id_str', conversationModel.get(conversationModel.count - 1).in_reply_to_status_id_str)
                    conversationStatus.id_str = in_reply_to_status_id_str
                } else {
//                    console.debug('adjustTimer.start()')
                    adjustTimer.start()
                }
            }
        }
//        onRunningChanged: console.debug('conversationTimer.running:', running, relatedResults.done, conversationStatus.loading)
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
        interactive: typeof root.linkMenu === 'undefined'

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
                    user: model.user
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
                    source: "http://maps.google.com/staticmap?zoom=15&center=" + _lat + "," + _long + "&size=240x240&markers=" + _lat + "," + _long + ",red,a&saturation=-100"
                    width: 240
                    height: 240
                    visible: typeof root.__status.geo !== 'undefined' && typeof root.__status.geo.coordinates !== 'undefined'
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
                        text: visible ? '<a style="'.concat(constants.placeStyle).concat('">').concat(root.__status.place.full_name).concat('</a>') : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontLarge
                        visible: typeof root.__status.place !== 'undefined' && typeof root.__status.place.full_name !== 'undefined'
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: visible ? '<a style="'.concat(constants.placeStyle).concat('">').concat(root.__status.place.country).concat('</a>') : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontLarge
                        visible: typeof root.__status.place !== 'undefined' && typeof root.__status.place.country !== 'undefined'
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
                    user: model.user
                    onClicked: pageStack.push(statusPage, {'id_str': model.id_str})
                    onLinkActivated: openLink(link)
                }
            }
        }
    }

    ScrollBar {
        anchors.top: parent.top; anchors.topMargin: root.headerHeight
        anchors.right: flickable.right
        height: flickable.contentY / 10
        width: constants.listViewScrollbarWidth
    }

    Menu {
        id: menu
        visualParent: flickable
        MenuLayout {
            id: menuLayout
//            MenuItemWithIcon {
//                id: translation
//                iconSource: 'image://theme/icon-m-toolbar-select-text'.concat(enabled ? "" : "-dimmed").concat(theme.inverted ? "-white" : "")
//                text: qsTr('Translate')
//                onClicked: delegate.translate()
//            }
            MenuItemWithIcon {
                property bool muted: window.filters.indexOf('@'.concat(root.__user.screen_name)) > -1
                iconSource: 'image://theme/icon-m-toolbar-volume'.concat(muted ? '' : '-off').concat(theme.inverted ? "-white" : "")
                text: muted ? qsTr('Unmute @%1').arg(root.__user.screen_name) : qsTr('Mute @%1').arg(root.__user.screen_name)
                onClicked: {
                    var filters = window.filters
                    if (muted) {
                        var index = filters.indexOf('@'.concat(root.__user.screen_name))
                        while (index > -1) {
                            filters.splice(index, 1)
                            index = filters.indexOf('@'.concat(root.__user.screen_name))
                        }
                    } else {
                        filters.unshift('@'.concat(root.__user.screen_name))
                    }
                    window.filters = filters
                }
            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-delete'.concat(enabled ? "" : "-dimmed").concat(theme.inverted ? "-white" : "")
                text: qsTr('Delete the tweet')
                enabled: status.user.id_str === oauth.user_id
                onClicked: status.destroyStatus()
            }

            Repeater {
                model: servicePlugins.pluginInfo
                delegate: MenuItemWithIcon {
                    id: customItem
                    iconSource: model.plugin.icon
                    text: model.plugin.service
                    property url link: 'http://twitter.com/' + __status.user.screen_name + '/status/' + __status.id_str
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
        onStatusChanged: root.linkMenu = (menu.status == DialogStatus.Closed ? undefined : menu)
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-reply"
//            iconSource: '../images/mentions'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                var entities = status.entities
                var statusText = '@'.concat(__user.screen_name).concat(' ')
                if (typeof entities.user_mentions.length !== 'undefined') {
                    for (var j = 0; j < entities.user_mentions.length; j++) {
                        var id_str = entities.user_mentions[j].id_str
                        if (id_str !== __user.id_str && id_str !== oauth.user_id) {
                            statusText = statusText.concat('@').concat(entities.user_mentions[j].screen_name).concat(' ')
                        }
                    }
                }
                if (typeof entities.hashtags.length !== 'undefined') {
                    for (var j = 0; j < entities.hashtags.length; j++) {
                        statusText = statusText.concat(' #').concat(entities.hashtags[j].text)
                    }
                }
                pageStack.push(tweetPage, {'statusText': statusText, 'in_reply_to': __status})
            }
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
            iconSource: '../images/retweet'.concat(theme.inverted ? '-white.png' : '.png')
            enabled: !root.__status.retweeted && (root.__retweeted ? true : !root.__user.protected)
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                if (__status.user.id_str == oauth.user_id || __status.retweeted) {
                    pageStack.push(tweetPage, {'statusText': ' RT @' + __status.user.screen_name + ': ' + __status.text.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&'), 'in_reply_to': __status})
                } else {
                    pageStack.push(tweetPage, {'in_reply_to': __status})
                }
            }
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
