import QtQuick 1.1
import QtMobility.location 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Location')
    busy: positionSource.loading || map.status !== Image.Ready

    PositionSource {
        id: positionSource
        updateInterval: 10000
        active: root.status === PageStatus.Active
        property bool loading: active && (!position.latitudeValid || !position.longitudeValid)
        property bool valid: active && position.latitudeValid && position.longitudeValid
    }

    Image {
        id: map
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        property double _lat: positionSource.valid ? positionSource.position.coordinate.latitude : 0.0
        property double _long: positionSource.valid ? positionSource.position.coordinate.longitude : 0.0
        source: positionSource.valid ? "http://maps.google.com/staticmap?zoom=17&center=" + _lat + "," + _long + "&size=" + width + "x" + height : ''

        Item {
            anchors.centerIn: parent
            height: pin.height * 2
            visible: positionSource.valid
            Image {
                id: pin
                source: 'http://maps.gstatic.com/mapfiles/markers2/marker.png'
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
            }
        }
        MouseArea {
            anchors.fill: parent
            enabled: positionSource.valid
            onClicked: {
                locationSelected = {'latitude': positionSource.position.coordinate.latitude, 'longitude': positionSource.position.coordinate.longitude }
                pageStack.pop()
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout { backOnly: true }
}
