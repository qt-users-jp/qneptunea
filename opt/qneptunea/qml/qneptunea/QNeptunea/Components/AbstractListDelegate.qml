import QtQuick 1.1

MouseArea {
    width: 100
    height: constants.fontDefault + 40

    property alias icon: icon.source
    property alias text: text.text
    property alias driilldown: drilldown.visible
    property alias separatorVisible: separator.visible
    property alias separatorColor: separator.color

    Item {
        id: iconArea
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        width: (icon.status === Image.Ready) ? 48 : 0
        height: 48
        Image {
            id: icon
            anchors.centerIn: parent
        }
    }

    Text {
        id: text
        anchors.left: iconArea.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font.bold: true
        font.family: constants.fontFamily
        font.pixelSize: constants.fontDefault
        color: constants.textColor
    }

    Image {
        id: drilldown
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        source: 'image://theme/icon-m-common-drilldown-arrow'.concat(theme.inverted ? "-inverse" : "")
    }

    Separator {
        id: separator
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -constants.separatorHeight / 2
        width: parent.width - constants.listViewScrollbarWidth
    }
}
