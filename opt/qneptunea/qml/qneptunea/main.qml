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
import QtMobility.systeminfo 1.1
import QtMobility.feedback 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.1
import QNeptunea 1.0
import 'Pages'
import 'QNeptunea/Components/'
import '../qneptunea-share'

PageStackWindow {
    id: window
    showToolBar: false

    function defined(obj) { return typeof obj !== 'undefined' }
    function to_s(obj, format) { return typeof obj === 'string' ? (defined(format) ? format.arg(obj) : obj) : '' }

    property alias logoVisible: logo.visible

    platformStyle: PageStackWindowStyle {
        background: constants.background
    }

    Timer {
        id: autoTestTimer
        interval: 10000
        repeat: false
        onTriggered: {
            console.debug('Test end')
            if (!autoTest.manual)
                autoTest.end(0)
        }
    }

    AutoTest {
        id: autoTest
        onStart: {
            console.debug('Test start')
            autoTestTimer.start()
        }
    }


    Timer {
        id: loadedTimer
        running: true
        interval: 5000
        repeat: false
    }

    Component { id: notification; Notification {} }
    HapticsEffect {
        id: rumbleEffect
        attackIntensity: 0.0
        attackTime: 250
        intensity: 1.0
        duration: 500
        fadeTime: 250
        fadeIntensity: 0.0
    }

    VerifyCredentials { id: verifyCredentials }

    Configuration { id: configuration }

    NoRetweetIdsModel { id: noRetweetIds }

    ShareInterface { id: share }

    PreviewPlugins { id: previewPlugins }
    TranslationPlugins { id: translationPlugins }
    ThemePlugins { id: themePlugins }
    ServicePlugins { id: servicePlugins }
    SettingsPlugins { id: settingsPlugins }
    TweetPlugins { id: tweetPlugins }

    property variant friends: []

    property variant filters: settings.readData('Filters', '').split(/\n/)
    property variant user_filters: []
    property variant hashtag_filters: []
    property variant url_filters: []
    property variant text_filters: []

    onFiltersChanged: {
        var user_filters = []
        var hashtag_filters = []
        var url_filters = []
        var text_filters = []
        for (var i = 0; i < window.filters.length; i++) {
            var f = window.filters[i]
            if (f[0] === '@') {
                user_filters.push(f.substring(1).toLowerCase())
            } else if (f[0] === '#') {
                hashtag_filters.push(f.substring(1).toLowerCase())
            } else if (f.substring(0, 7) === 'http://' || f.substring(0, 8) === 'https://') {
                url_filters.push(f)
            } else if (f.length > 0){
                text_filters.push(f.toLowerCase())
            }
        }

        window.user_filters = user_filters
        window.hashtag_filters = hashtag_filters
        window.url_filters = url_filters
        window.text_filters = text_filters
        settings.saveData('Filters', window.filters.join('\n'))
    }

    function filter(item) {
        var status = item
        if (typeof item.retweeted_status !== 'undefined') {
            if (noRetweetIds.idList.indexOf(item.user.id_str) > -1) return true
            status = item.retweeted_status
        }
        var entities = status.entities
        var text = status.plain_text.toLowerCase()

        if (typeof status.user !== 'undefined') {
            if (user_filters.indexOf(item.user.screen_name.toLowerCase()) > -1) return true
            if (typeof entities !== 'undefined' && typeof entities.user_mentions.length !== 'undefined') {
                for (var i = 0; i < entities.user_mentions.length; i++) {
                    if (user_filters.indexOf(entities.user_mentions[i].screen_name.toLowerCase()) > -1) return true
                }
            }
        }

        if (typeof entities !== 'undefined' && typeof entities.hashtags.length !== 'undefined') {
            for (var i = 0; i < entities.hashtags.length; i++) {
                if (hashtag_filters.indexOf(entities.hashtags[i].text.toLowerCase()) > -1) return true
            }
        }

        if (typeof entities !== 'undefined' && typeof entities.urls.length !== 'undefined') {
            for (var i = 0; i < entities.urls.length; i++) {
                var url = entities.urls[i].expanded_url.toLowerCase()
                for (var j = 0; j < url_filters.length; j++) {
                    if (url.substring(0, url_filters[j].length) === url_filters[j]) return true
                }
            }
        }

        for (var i = 0; i < text_filters.length; i++) {
            if (text.indexOf(text_filters[i]) > -1) return true
        }

        return false;
    }

    CurrentVersion {
        id: currentVersion
        version: settings.readData('System/Version')
        onVersionChanged: settings.saveData('System/Version', version)
    }

    UpdateChecker { id: updateChecker }

    property bool active: platformWindow.viewMode === WindowState.Fullsize && platformWindow.visible && platformWindow.active
    onActiveChanged: {
        if (active) {
            clearNotifications();
        }
    }

    function clearNotifications(component) {
        var create = (typeof component === 'undefined')
        if (create)
            component = notification.createObject(window)
        var notifications = component.notifications()
        for (var i = 0; i < notifications.length; i++) {
            if (!create && component.eventType !== notifications[i].eventType)
                continue
            notifications[i].remove()
            notifications[i].destroy()
        }
        if (create)
            component.destroy()
    }

    ScreenSaver { screenSaverInhibited: window.active && constants.screenSaverDisabled }

    Image {
        id: logo
        x: (constants.headerHeight - logo.height) / 2
        y: (constants.headerHeight - logo.height) / 2 + constants.statusBarHeight
        Behavior on y {
            SequentialAnimation {
                PauseAnimation { duration: 350 }
                NumberAnimation { properties: 'y' }
            }
        }

        source: constants.logo
        opacity: 0.0

        states: [
            State {
                name: "test.ok"
                when: test.online
                PropertyChanges {
                    target: logo
                    opacity: 1.0
                }
            },
            State {
                name: "online"
                when: networkConfigurationManager.online
                PropertyChanges {
                    target: logo
                    opacity: 0.25
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {}
            }
        ]
    }

    StateGroup {
        id: orientation
        states: [
            State {
                name: "landscape"
                when: !window.inPortrait
                PropertyChanges {
                    target: window
                    showStatusBar: false
                }
            }
        ]

        transitions: [
            Transition {
                from: 'landscape'
                SequentialAnimation {
                    PauseAnimation { duration: 350 }
                    NumberAnimation { properties: 'y' }
                }
            },
            Transition {
                to: 'landscape'
                NumberAnimation { properties: 'y'; duration: 350 }
            }
        ]
    }

    UIConstants { id: constants }

    Binding { target: theme; property: 'inverted'; value: constants.themeInverted }
    Binding { target: theme; property: 'colorScheme'; value: constants.themeColorScheme }

    Column {
        id: infoBanners
        y: constants.headerHeight + constants.statusBarHeight + 8
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        function followedBy(status) {
            if (status.source.id_str === oauth.user_id) return
            var properties = {
                text: qsTr('@%1 following you').arg(status.source.screen_name)
                , iconSource: status.source.profile_image_url
                , page: userPage
                , properties: { id_str: status.source.id_str }
            }
            infoBannerComponent.createObject(infoBanners, properties).show()
        }

        function favorited(status) {
            if (status.source.id_str === oauth.user_id) return
            var properties = {
                text: qsTr('@%1 favorited your tweet\n%2').arg(status.source.screen_name).arg(status.target_object.text)
                , iconSource: status.source.profile_image_url
                , page: statusPage
                , properties: { id_str: status.target_object.id_str }
            }
            infoBannerComponent.createObject(infoBanners, properties).show()
        }

        function message(properties) {
            infoBannerComponent.createObject(infoBanners, properties).show()
        }

        function rateLimitMessage(xrlLimit, xrlRemaining, xrlReset) {
            var xrlResetSec = Math.floor((xrlReset.getTime() - new Date().getTime()) / 1000)
            var xrlResetSecString = xrlResetSec < 5 ? qsTr('in seconds') : qsTr('in another %1 seconds').arg(xrlResetSec)

            var properties = {
                'iconSource': 'image://theme/icon-m-presence-busy'
                , 'text': qsTr('API rate limit has exceeded(%1/%2), \nwill be reset %3').arg(xrlRemaining).arg(xrlLimit).arg(xrlResetSecString)
            }
            message(properties)
        }
    }

    Component {
        id: infoBannerComponent
        InfoBanner {
            id: infoBanner
            timerEnabled: platformWindow.viewMode === WindowState.Fullsize && platformWindow.visible && platformWindow.active
            timerShowTime: 5000
            property Component page
            property variant properties

            onScaleChanged: {
                if (scale == 0 && infoBanner.text.length > 0) {
                    infoBanner.destroy()
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (mouse.x < width - height && infoBanner.page) {
                        pageStack.push(infoBanner.page, infoBanner.properties)
                    }
                    infoBanner.hide()
                }
            }

            ToolButton {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                width: 45
                height: 45
                iconSource: 'image://theme/icon-m-toolbar-close'.concat(theme.inverted ? "-white" : "")
                onClicked: infoBanner.hide()
            }
        }
    }


    property variant mediaSelected
    property variant locationSelected
    property bool shortcutAdded: false

    SettingsStorage {
        id: settings
        identifier: 'QNeptunea'
        description: 'http://twitter.com/task_jp'
    }


    QtObject {
        id: test
        property bool online: networkConfigurationManager.online && test.ok
        property bool ok: false

        function exec() {
            var request = new XMLHttpRequest()
            request.open('GET', 'https://api.twitter.com/1.1/help/tos.json')
            request.setRequestHeader("Content-Type", "application/json")
            request.onreadystatechange = function() {
                        if( request.readyState === XMLHttpRequest.HEADERS_RECEIVED && request.status !== 0 ) {
                            test.ok = true
                        }
                    }
            request.send()
        }
    }

    Timer {
        running: networkConfigurationManager.online && constants.streaming && !test.ok
        interval: 30 * 1000
        triggeredOnStart: true
        repeat: true
        onTriggered: test.exec()
    }

    Timer {
        running: !constants.streaming && interval > 0 && !test.online
        interval: constants.updateInterval * 60 * 1000
        repeat: true
        onTriggered: test.exec()
    }

    OAuth {
        id: oauth
        consumer_key: consumerKey
        consumer_secret: consumerSecret
        token: settings.readData('OAuth/Token', '')
        token_secret: settings.readData('OAuth/TokenSecret', '')
        user_id: settings.readData('OAuth/UserId', '')
        screen_name: settings.readData('OAuth/ScreenName', '')
        onTokenChanged: settings.saveData('OAuth/Token', token)
        onToken_secretChanged: settings.saveData('OAuth/TokenSecret', token_secret)
        onUser_idChanged: settings.saveData('OAuth/UserId', user_id)
        onScreen_nameChanged: settings.saveData('OAuth/ScreenName', screen_name)

        property bool completed: false
        onStateChanged: {
            switch (state) {
            case OAuth.Authorized:
                if (completed) {
                    verifyCredentials.exec()
                    configuration.exec()
                }
                break
            case OAuth.Unauthorized:
                if (completed) {
                    settings.saveData('Mute/IDs', '')
                    settings.saveData('MentionsTimelinePage/maxLoadedIdStr', '')
                    for (var i = 0; i < 6; i++) {
                        if (i < shortcutModel.count) {
                            var item = shortcutModel.get(i)
                            settings.saveData('Shortcuts/'.concat(i).concat('/icon'), '')
                            settings.saveData('Shortcuts/'.concat(i).concat('/link'), '')
                        }
                    }
                }
                break
            }
        }
        Component.onCompleted: oauth.completed = true
    }


    initialPage: mainPage
//    initialPage: settingsPage
//    initialPage: authorizationPage
//    initialPage: SplashPage {}



    SavedSearchesModel {
        id: savedSearchesModel
        property variant searchTerms: []
        onSizeChanged: setSearchTermDelayed.running = true

        Timer {
            id: setSearchTermDelayed
            repeat: false
            running: false
            interval: 100
            onTriggered: {
                var searchTerms = []
                for (var i = 0; i < savedSearchesModel.size; i++) {
                    searchTerms.push(savedSearchesModel.get(i).query.toLowerCase())
                }
                savedSearchesModel.searchTerms = searchTerms
            }
        }

//        onSearchTermsChanged: console.debug("savedSearchesModel.searchTerms.join(',')", savedSearchesModel.searchTerms.join(','))
    }

    ListModel {
        id: shortcutModel

        Component.onCompleted: readData();
        Component.onDestruction: saveData();
        function readData() {
            for (var i = 0; i < 6; i++) {
//                var type = settings.readData('Shortcuts/'.concat(i).concat('/type'), 'string');
                var icon = settings.readData('Shortcuts/'.concat(i).concat('/icon'), '');
                var link = settings.readData('Shortcuts/'.concat(i).concat('/link'), '')
                if (icon.length == 0) {
                    break
                }

                shortcutModel.append({ 'gridId': i, 'icon': icon, 'link': link })
            }
        }

        function saveData() {
            for (var i = 0; i < 6; i++) {
                if (i < shortcutModel.count) {
                    var item = shortcutModel.get(i)
                    settings.saveData('Shortcuts/'.concat(i).concat('/icon'), item.icon);
                    settings.saveData('Shortcuts/'.concat(i).concat('/link'), item.link)
                } else {
                    settings.saveData('Shortcuts/'.concat(i).concat('/icon'), '');
                    settings.saveData('Shortcuts/'.concat(i).concat('/link'), '')
                }
            }
        }
    }

    Component { id: authorizationPage; AuthorizationPage {} }
    MainPage {id: mainPage}
    Component { id: userPage; UserPage {} }
    Component { id: statusPage; StatusPage {} }
    TweetPage { id: tweetPage }
    Component { id: searchPage; SearchPage {} }
    Component { id: imagePreviewPage; ImagePreviewPage {} }
    Component { id: youtubePreviewPage; YoutubePreviewPage {} }
    Component { id: slidesharePreviewPage; SlidesharePreviewPage {} }
    Component { id: userTimelinePage; UserTimelinePage {} }
    Component { id: favouritesPage; FavouritesPage {} }
    Component { id: followingPage; FollowingPage {} }
    Component { id: followersPage; FollowersPage {} }
    Component { id: directMessagePage; DirectMessagePage {} }
    SendDirectMessagePage {id: sendDirectMessagePage}
    Component { id: listsPage; ListsPage {} }
    Component { id: listedPage; ListedPage {} }
    Component { id: listStatusesPage; ListStatusesPage {} }
    Component { id: selectMediaPage; SelectMediaPage {} }
    Component { id: selectLocationPage; SelectLocationPage {} }
    Component { id: legalPage; LegalPage {} }
    Component { id: suggestionsPage; SuggestionsPage {} }
    Component { id: searchUsersPage; SearchUsersPage {} }
    SettingsPage {id: settingsPage}
    Component { id: mapPage; MapPage {} }
    Component { id: aboutPage; AboutPage {} }
    Component { id: trendPage; TrendPage {} }
    Component { id: slugPage; SlugPage {} }
    Component { id: nearByPage; NearByPage {} }
    Component { id: themePage; ThemePage {} }
    Component { id: mutePage; MutePage {} }

    Component { id: placeComponent; Place {} }
    Component { id: retweetedByComponent; RetweetedBy {} }

    TextEdit { id: clipboard; visible: false }

    Component.onCompleted: {
        app.visible = true
    }
}
