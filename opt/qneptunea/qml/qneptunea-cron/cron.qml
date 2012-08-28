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
import QtMobility.feedback 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import QNeptunea 1.0
import '../qneptunea-share'

Window {
    id: window

    SettingsStorage {
        id: settings
        identifier: 'QNeptunea'
        description: 'http://twitter.com/task_jp'
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
            status = item.retweeted_status
        }
        var entities = status.entities
        var text = status.text.toLowerCase()

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

    Mentions { id: mentions }
    DirectMessages { id: directMessages }
    SavedSearches { id: savedSearches }

    function clearNotifications(component) {
        var notifications = component.notifications()
        console.debug('notifications', typeof notifications)
        console.debug('notifications', notifications.length)
        for (var i = 0; i < notifications.length; i++) {
            if (component.eventType !== notifications[i].eventType)
                continue
            notifications[i].remove()
            notifications[i].destroy()
        }
    }

    Timer {
        running: (mentions.done && directMessages.done && savedSearches.done) || oauth.state !== OAuth.Authorized
        interval: 500
        repeat: false
        onTriggered: Qt.quit()
    }
}

