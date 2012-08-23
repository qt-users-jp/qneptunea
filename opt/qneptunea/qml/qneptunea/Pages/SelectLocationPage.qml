import QtQuick 1.1
import QtWebKit 1.0
import QtMobility.location 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Location')
    busy: positionSource.loading || map.loading

    property double _lat: positionSource.valid ? positionSource.position.coordinate.latitude : 0.0
    property double _long: positionSource.valid ? positionSource.position.coordinate.longitude : 0.0

    PositionSource {
        id: positionSource
        updateInterval: 5000
        active: root.status === PageStatus.Active
        property bool loading: active && (!position.latitudeValid || !position.longitudeValid)
        property bool valid: active && position.latitudeValid && position.longitudeValid
    }

    WebView {
        id: map
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        preferredWidth: width
        preferredHeight: height
        url: 'GoogleMaps.html'

        property bool loading: false
        onLoadStarted: loading = true
        onLoadFinished: loading = false
        onAlert: console.debug('alert:', message)

        javaScriptWindowObjects: QtObject {
            id: js
            WebView.windowObjectName: "qml"
            property real lat: root._lat
            property real lng: root._long
            onLatChanged: map.evaluateJavaScript('updatePosition()')
            onLngChanged: map.evaluateJavaScript('updatePosition()')
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        backOnly: true
        ToolButton {
            enabled: positionSource.valid
            checked: enabled
            text: 'OK'
            onClicked: {
                locationSelected = {'latitude': positionSource.position.coordinate.latitude, 'longitude': positionSource.position.coordinate.longitude }
                pageStack.pop()
            }
        }

        ToolIcon {
            iconSource: '../images/zoom-in'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: map.evaluateJavaScript('zoomIn()')
        }
        ToolIcon {
            iconSource: '../images/zoom-out'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: map.evaluateJavaScript('zoomOut()')
        }
    }
}
