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

