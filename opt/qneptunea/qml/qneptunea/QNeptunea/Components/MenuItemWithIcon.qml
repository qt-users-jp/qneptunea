import QtQuick 1.1
import com.nokia.meego 1.0

MenuItem {
    id: root
    property alias iconSource: icon.source
    Image {
        id: icon
        anchors.right: parent.right
        anchors.rightMargin: (40 - width) / 2 + 24
        anchors.verticalCenter: parent.verticalCenter
        opacity: root.enabled ? 1.0 : 0.5
    }
}
