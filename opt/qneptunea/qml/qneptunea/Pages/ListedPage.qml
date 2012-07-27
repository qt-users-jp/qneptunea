import QtQuick 1.1
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: screen_name ? '@' + screen_name: ''
    busy: model.loading


    ListListView {
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: ListsMembershipsModel { id: model; user_id: root.id_str }
        onShowDetail: pageStack.push(listStatusesPage, {'id_str': detail.id_str})
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(screen_name).concat('&size=bigger')
            shortcutUrl: 'listed://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolSpacer {}
    }
}
