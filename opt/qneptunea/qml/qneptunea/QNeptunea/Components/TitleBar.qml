import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: root
    width: 100
    height: constants.headerHeight

    property alias text: title.text
    property alias busy: busy.running

    Text {
        id: title
        anchors.centerIn: parent
        color: constants.titleColor
        font.bold: true
        font.pixelSize: constants.titleFontPixelSize
        font.family: constants.fontFamily
    }

    BusyIndicator {
        id: busy
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        platformStyle: BusyIndicatorStyle {}
        visible: running
    }
}
