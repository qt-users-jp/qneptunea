import QtQuick 1.1
import Twitter4QML 1.0
import QNeptunea 1.0

MentionsModel {
    id: model
    property bool done: false

    count: 200
    sortKey: 'id_str'
    since_id: settings.readData('MentionsPage/maxReadIdStr', '')

    onLoadingChanged: {
        if (loading) {
            //                console.debug('since_id', since_id)
        } else {
            if (model.size > 0 && model.get(0).id_str !== settings.readData('MentionsPage/maxLoadedIdStr', '')) {
                var component = notification.createObject(window)
                component.eventType = 'qneptunea.mentions'
                component.image = settings.readData('Theme/NotificationIconForMentions', 'icon-m-service-qneptunea-mention')
                window.clearNotifications(component)
                var item = model.get(0)
                component.summary = item.user.name.concat(' @').concat(item.user.screen_name)
                if (model.size == 1) {
                    component.body = '1 new mention'
                } else {
                    component.body = model.size + ' new mentions'
                }
                component.identifier = 'mentions'
                component.count = model.size

                if (component.publish() && settings.readData('Notifications/HapticsFeedback', false))
                    rumbleEffect.start()
                settings.saveData('MentionsPage/maxLoadedIdStr', model.get(0).id_str)
            }
            model.done = true
        }
    }
}

