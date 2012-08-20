import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: root
    width: 100
    height: constants.headerHeight

    property alias text: title.text
    property alias busy: busy.running

    AutoScrollText {
        id: title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Math.max(2 * logo.x + logo.width, root.width - busy.x)
        color: constants.titleColor
        font.bold: true
        font.pixelSize: constants.titleFontPixelSize
        font.family: constants.fontFamily
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
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
