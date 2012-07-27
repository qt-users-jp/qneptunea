import QtQuick 1.1
import Twitter4QML 1.0
import QNeptunea 1.0

import QtQuick 1.1
import Twitter4QML 1.0
import QNeptunea 1.0

DirectMessagesModel {
    id: model
    property bool done: false

    count: 200
    sortKey: 'id_str'
    since_id: settings.readData('DirectMessagesPage/maxReadIdStr', '')

    onLoadingChanged: {
        if (loading) {
            //                console.debug('since_id', since_id)
        } else {
            if (model.size > 0 && model.get(0).id_str !== settings.readData('DirectMessagesPage/maxReadIdStr', '')) {
                var component = notification.createObject(window)
                component.eventType = 'qneptunea.messages'
                component.image = settings.readData('Theme/NotificationIconForMessages', 'icon-m-service-qneptunea-message')
                window.clearNotifications(component)
                var item = model.get(0)
                component.summary = item.sender.name.concat(' @').concat(item.sender.screen_name)
                if (model.size == 1) {
                    component.body = '1 new message'
                } else {
                    component.body = model.size + ' new messages'
                }
                component.identifier = 'messages'
                component.count = model.size

                if (component.publish() && settings.readData('Notifications/HapticsFeedback', false))
                    rumbleEffect.start()
                settings.saveData('DirectMessagesPage/maxReadIdStr', model.get(0).id_str)
            }
            model.done = true
        }
    }
}
