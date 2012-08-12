import QtQuick 1.1
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: '@' + root.screen_name
    busy: model.loading

    property int __topIndex: view.indexAt(0, view.contentY)
    property variant __topData: model.get(__topIndex)

    StateGroup {
        states: [
            State {
                name: "show time"
                when: view.moving && __topData.created_at
                PropertyChanges {
                    target: root
                    title: Qt.formatDateTime(new Date(__topData.created_at), qsTr('M/d hh:mm'))
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    StatusListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: UserTimelineModel {
            id: model
            user_id: root.id_str
            sortKey: 'id_str'
            count: 50
            contributor_details: true
        }
        onReload: {
            model.since_id = model.size == 0 ? '' : model.get(0).id_str
            model.max_id = ''
            model.reload()
        }
        onMore: {
            model.max_id = model.size == 0 ? '' : model.get(model.size - 1).id_str
            model.since_id = ''
            model.reload()
        }
        onShowDetail: pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: root.openLink(link)
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(screen_name).concat('&size=bigger')
            shortcutUrl: 'usertimeline://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolSpacer {}
    }
}
