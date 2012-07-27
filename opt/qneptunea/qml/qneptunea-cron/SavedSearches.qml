import QtQuick 1.1
import Twitter4QML 1.0
import Twitter4QML.extra 1.0
import QNeptunea 1.0

Item {
    id: root
    property bool done: false

    Timer {
        running: true
        repeat: false
        interval: 1000 * 30
        onTriggered: root.done = true // fail safe
    }

    Component {
        id: searchModel
        SearchStatusesModel {
            id: searchStatuses
            rpp: 200
            sortKey: 'id_str'
            since_id: settings.readData('SavedSearchStreamPage/maxReadIdStr', '')
        }
    }

    SavedSearchesModel {
        id: savedSearchesModel
        property variant searchTerms: []
        onLoadingChanged: {
            if (loading) return
            if (savedSearchesModel.size > 0) {
                var searchTerms = []
                for (var i = 0; i < savedSearchesModel.size; i++) {
                    searchTerms.push(get(i).query.toLowerCase())
                }
                savedSearchesModel.searchTerms = searchTerms
            } else {
                root.done = true
            }
        }
    }

    Component.onCompleted: resetModels()
    Connections {
        target: savedSearchesModel
        onSearchTermsChanged: resetModels()
    }
    function resetModels() {
        for (var j = 0; j < savedSearchesModel.searchTerms.length; j++) {
            model.addModel(searchModel.createObject(model, {'q': unescape(savedSearchesModel.searchTerms[j])}))
        }
    }

    UnionModel {
        id: model
        onLoadingChanged: {
            if (loading) {
                //                console.debug('since_id', since_id)
            } else {
                if (model.size > 0 && model.get(0).id_str !== settings.readData('SavedSearchStreamPage/maxLoadedIdStr', '')) {
                    var component = notification.createObject(window)
                    component.eventType = 'qneptunea.searches'
                    component.image = settings.readData('Theme/NotificationIconForSearches', 'icon-m-service-qneptunea-search')
                    window.clearNotifications(component)
                    var item = model.get(0)
                    component.summary = item.user.name.concat(' @').concat(item.user.screen_name)
                    if (model.size == 1) {
                        component.body = '1 new search'
                    } else {
                        component.body = model.size + ' new searches'
                    }
                    component.identifier = 'searches'
                    component.count = model.size

                    if (component.publish() && settings.readData('Notifications/HapticsFeedback', false))
                        rumbleEffect.start()
                    settings.saveData('SavedSearchStreamPage/maxLoadedIdStr', model.get(0).id_str)
                }
                root.done = true
            }
        }
    }
}

