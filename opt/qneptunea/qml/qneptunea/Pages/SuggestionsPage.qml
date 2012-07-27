import QtQuick 1.1
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: root.screen_name
    busy: model.loading

    property alias lang: model.lang

    UserListView {
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: SuggestionsModel {
            id: model
            slug: root.id_str
        }
        onShowDetail: pageStack.push(userPage, {'id_str': detail.id_str})
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
