import QtQuick 1.1
import QtWebKit 1.0
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Map')
    busy: map.loading

    property double _lat
    property double _long

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
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
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
