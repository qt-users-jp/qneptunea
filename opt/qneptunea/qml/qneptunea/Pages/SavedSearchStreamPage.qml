import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import Twitter4QML.extra 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: qsTr('Saved Search Timeline')
    busy: model.loading
    onHeaderClicked: if (!model.loading) view.positionViewAtBeginning()

    property bool active: false
    property string __maxReadIdStr: settings.readData('SavedSearchStreamPage/maxReadIdStr', '')
    property variant topData: model.get(view.topItemIndex)
    onTopDataChanged: refresh.toBeRefreshed = true
    property int unreadCount: 0

    Timer {
        id: refresh
        property bool toBeRefreshed: true
        running: refresh.toBeRefreshed && !model.loading
        interval: 250
        repeat: false
        onTriggered: {
            if (view.count > 0) {
                var id_str = model.get(Math.max(0, view.topItemIndex)).id_str
                if (root.__maxReadIdStr.length < id_str.length) {
                    root.__maxReadIdStr = id_str
                } else if (root.__maxReadIdStr.length == id_str.length && root.__maxReadIdStr < id_str) {
                    root.__maxReadIdStr = id_str
                } else if (view.atYBeginning && root.__maxReadIdStr.length == 0) {
                    root.__maxReadIdStr = id_str
                }
                root.unreadCount = model.indexOf(root.__maxReadIdStr)

                if (root.unreadCount > 0 && !window.active) {
                    var component = notification.createObject(window)
                    component.eventType = 'qneptunea.searches'
                    component.image = constants.notificationIconForSearches
                    window.clearNotifications(component)
                    var item = model.get(0)
                    component.summary = item.user.name.concat(' @').concat(item.user.screen_name)
                    if (root.unreadCount == 1) {
                        component.body = '1 new search'
                    } else if (root.unreadCount > 1){
                        component.body = root.unreadCount + ' new searches'
                    }
                    component.identifier = 'searches'
                    component.count = root.unreadCount

                    if (component.publish() && constants.notificationsWithHapticsFeedback)
                        rumbleEffect.start()
                }
            }
            refresh.toBeRefreshed = false
        }
    }

    function moveToTop() {
        if (root.topData.id_str == root.__maxReadIdStr || root.unreadCount == 0)
            view.positionViewAtBeginning()
        else
            view.positionViewAtIndex(root.unreadCount - 1, ListView.Beginning)
    }

    property bool loadedUntilLastPos: false
    function updateLoadedUntilLastPos() {
        var loadedUntilLastPos = true
        for (var i = 0; i < model.childObjects.length; i++) {
            if (!model.childObjects[i].streaming && model.childObjects[i].loadingUntilLastPos) {
                loadedUntilLastPos = false
                break
            }
        }
        root.loadedUntilLastPos = loadedUntilLastPos
    }

    Timer {
        id: positionViewAtBeginning
        running: root.loadedUntilLastPos
        repeat: false
        interval: 500
        onTriggered: {
            view.positionViewAtBeginning()

            for (var i = 0; i < model.childObjects.length; i++) {
                if (!model.childObjects[i].streaming)
                    model.childObjects[i].loadUntilLatest()
            }
        }
    }
    StateGroup {
        states: [
            State {
                name: 'fake visible'
                when: root.parent.visible && !root.loadedUntilLastPos
                PropertyChanges {
                    target: root
                    visible: true
                    opacity: 0
                }
            },
            State {
                name: "page stack is available"
                when: typeof pageStack === 'object'
                PropertyChanges {
                    target: refresh
                    running: refresh.toBeRefreshed && !model.loading && pageStack.depth == 1
                }
            }
        ]
    }

    property string created_at

    StateGroup {
        states: [
            State {
                name: "show time"
                when: view.moving && topData.created_at
                PropertyChanges {
                    target: root
                    created_at: topData.created_at
                    title: Qt.formatDateTime(new Date(root.created_at), 'M/d hh:mm')
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    Component {
        id: searchModel
        SearchStatusesModel {
            id: searchStatuses
            rpp: 50
            pushOrder: SearchStatusesModel.PushAtOnce
            sortKey: 'id_str'
            max_id: constants.restoringLastPositionDisabled ? '' : root.__maxReadIdStr
            onFiltering: if (window.filter(value)) searchStatuses.filter();
            property bool loadingUntilLastPos: true
            property bool loadingUntilLatest: false
            property int lastSize: 0

            function loadUntilLatest() {
                searchStatuses.pushOrder = SearchStatusesModel.PushOlderToNewer
                loadingUntilLatest = true
                lastSize = size
                since_id = size > 0 ? get(0).id_str : ''
                max_id = ''
                rpp = 100
                page = 1
                reload()
                if (view.atYBeginning)
                    view.contentY++
            }

            onLoadingChanged: {
                if (loading) {
//                        console.debug('loading:', max_id, since_id, size, lastSize)
                } else {
//                        console.debug('loaded:', max_id, since_id, size, lastSize)
                    if (loadingUntilLastPos) {
                        loadingUntilLastPos = false
                        root.updateLoadedUntilLastPos()
                    } else if (loadingUntilLatest) {
                        if (lastSize == size) {
                            loadingUntilLatest = false
                        } else {
                            lastSize = size
                            page++
                            reload()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: resetModels()
    Connections {
        target: savedSearchesModel
        onSearchTermsChanged: resetModels()
    }

    function resetModels() {
        for (var i = 0; i < model.childObjects.length; i++) {
            var child = model.childObjects[i]
            console.debug(i, typeof child)
            child.destroy()
        }
        for (var j = 0; j < savedSearchesModel.searchTerms.length; j++) {
            model.addModel(searchModel.createObject(model, {'q': unescape(savedSearchesModel.searchTerms[j])}))
        }
    }

    StatusListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        loading: model.loading
        active: root.active || !root.loadedUntilLastPos
        model: UnionModel {
            id: model
            property int lastSize: 0
            onSizeChanged: {
                var loadingUntilLastPos = false
                var loadingUntilLatest = false
                for (var i = 0; i < model.childObjects.length; i++) {
                    if (model.childObjects[i].loadingUntilLastPos) {
                        loadingUntilLastPos = true
                        break
                    }
                    if (model.childObjects[i].loadingUntilLatest) {
                        loadingUntilLatest = true
                        break
                    }
                }

                model.lastSize = model.size
                refresh.toBeRefreshed = true
            }
        }
        FilterStreamModel {
            id: filterStream
            enabled: test.online && constants.streaming
            track: savedSearchesModel.searchTerms.join(',')
        }
        onTopItemIndexChanged: refresh.toBeRefreshed = true
        onReload: {
            if (test.online) {
                for (var i = 0; i < model.childObjects.length; i++) {
                    var child = model.childObjects[i]
                    if (!child.loading) {
                        child.loadUntilLatest()
                    }
                }
            }
        }
        onMore: {
            for (var i = 0; i < model.childObjects.length; i++) {
                var child = model.childObjects[i]
                if (!child.loading) {
                    if (!child.streaming) {
                        child.pushOrder = SearchStatusesModel.PushNewerToOlder
                        child.max_id = child.size == 0 ? '' : child.get(child.size - 1).id_str
                        child.rpp = 20
                        child.since_id = ''
                        child.reload()
                    }
                }
            }
        }
        onShowDetail: if (state != 'loading') pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: {
            if (state != 'loading') {
                root.openLink(link)
            }
        }

        states: [
            State {
                name: 'loading'
                when: model.loading
                PropertyChanges {
                    target: view
                    interactive: false
                    opacity: 0.5
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { properties: 'opacity' }
            }
        ]
    }

    Timer {
        running: !constants.streaming && interval > 0 && test.online
        interval: constants.updateInterval * 60 * 1000
        repeat: true
        onTriggered: {
            for (var i = 0; i < model.childObjects.length; i++) {
                if (!model.childObjects[i].streaming)
                    model.childObjects[i].loadUntilLatest()
            }
        }
    }

    Connections {
        target: oauth
        onStateChanged: {
            if (oauth.state === OAuth.Unauthorized) {
                settings.saveData('SavedSearchStreamPage/maxReadIdStr', '')
            }
        }
    }

    Component.onDestruction: {
        if (oauth.state === OAuth.Authorized) {
            settings.saveData('SavedSearchStreamPage/maxReadIdStr', root.__maxReadIdStr)
        }
    }

    Connections {
        target: test
        onOnlineChanged: {
            if (test.online) {
                for (var i = 0; i < model.childObjects.length; i++) {
                    var child = model.childObjects[i]
                    if (!child.loading) {
                        if (!child.streaming) {
                            child.loadUntilLatest()
                        }
                    }
                }
            }
        }
    }
}
