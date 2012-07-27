import QtQuick 1.1
import com.nokia.meego 1.0

Row {
    id: root
    anchors.right: parent.right
    spacing: constants.listViewMargins
    property variant place

    Text {
        anchors.bottom: parent.bottom
        text: qsTr('<a style="%2">%1</a>').arg(typeof place.full_name !== 'undefined' ? place.full_name : '').arg(constants.placeStyle)
        font.family: constants.fontFamily
        font.pixelSize: constants.fontSmall
        color: constants.textColor
    }

    Image {
        width: constants.fontSmall
        height: constants.fontSmall
        smooth: true
        source: 'image://theme/icon-s-location-picker'.concat(theme.inverted ? "-inverse" : "")
        anchors.verticalCenter: parent.verticalCenter
    }
}
