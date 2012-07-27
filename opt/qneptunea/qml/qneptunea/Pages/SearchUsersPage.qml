import QtQuick 1.1
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: root.id_str
    busy: model.loading

    UserListView {
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: SearchUsersModel { id: model; q: root.id_str }
        onShowDetail: pageStack.push(userPage, {'id_str': detail.id_str})
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'image://theme/icon-l-search'
            shortcutUrl: 'searchusers://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolSpacer {}
    }
}
