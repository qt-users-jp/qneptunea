import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: root
    width: 400
    height: constants.listViewIconSize + 12
    property int height2: constants.listViewIconSize + 12

    property variant trend

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        anchors.bottom: parent.bottom
        height: constants.separatorHeight
        color: constants.separatorNormalColor
        opacity: constants.separatorOpacity
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: constants.listViewScrollbarWidth

        text: trend.name
        font.bold: true
        font.family: constants.fontFamily
        font.pixelSize: constants.fontDefault
        color: constants.textColor
    }
}
