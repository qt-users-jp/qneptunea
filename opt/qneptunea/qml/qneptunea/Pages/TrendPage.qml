import QtQuick 1.1
import Twitter4QML 1.0
import '../Views'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Trend')
    busy: trendsModel.loading

    Settings {
        id: settings
        onLoadingChanged: {
            if (!loading) {
                if (settings.trend_location.length > 0) {
                    trendsModel.woeid = settings.trend_location[0].woeid
//                    console.debug(settings.trend_location[0].woeid)
                }
            }
        }
    }

    TrendListView {
        id: trendsView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        model: TrendsModel { id: trendsModel }
        onShowDetail: pageStack.push(searchPage, {'id_str': detail.name})
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
