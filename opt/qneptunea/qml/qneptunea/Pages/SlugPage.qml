import QtQuick 1.1
import Twitter4QML 1.0
import '../Views'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Suggestions')
    busy: slugsModel.loading

    Settings {
        id: settings
    }

    SlugListView {
        id: suggestionsView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        model: SlugsModel { id: slugsModel; lang: settings.language }
        onShowDetail: pageStack.push(suggestionsPage, {'id_str': detail.slug, 'screen_name': detail.name, 'lang': settings.language})
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
