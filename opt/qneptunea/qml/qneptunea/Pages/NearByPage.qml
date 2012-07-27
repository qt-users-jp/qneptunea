import QtQuick 1.1
import QtMobility.location 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../Views'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Near by')
    busy: positionSource.loading || searchModel.loading

    PositionSource {
        id: positionSource
        updateInterval: 10000
        active: root.status === PageStatus.Active
        property bool loading: active && (!position.latitudeValid && !position.longitudeValid)
        property bool valid: active && position.latitudeValid && position.longitudeValid
    }

    SearchListView {
        id: locationView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        model: SearchModel { id: searchModel }

        states: [
            State {
                when: positionSource.valid
                PropertyChanges {
                    target: searchModel
                    geocode: positionSource.position.coordinate.latitude + ',' + positionSource.position.coordinate.longitude + ',1km'
                }
            }
        ]

        onShowDetail: pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: root.openLink(link)
    }

    toolBarLayout: AbstractToolBarLayout { ToolSpacer {columns: 4} }
}
