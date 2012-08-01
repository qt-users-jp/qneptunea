import QtQuick 1.1
import com.nokia.meego 1.0

Row {
    id: root
    anchors.right: parent.right
    spacing: constants.listViewMargins
    property variant place

    Text {
        anchors.bottom: parent.bottom
        text: '<a style="'.concat(constants.placeStyle).concat('">').concat(typeof place.full_name !== 'undefined' ? place.full_name : '').concat('</a>')
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
