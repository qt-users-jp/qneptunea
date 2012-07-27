import QtQuick 1.1
import com.nokia.meego 1.0

Image {
    id: root

    property bool loading: (status !== Image.Ready) & visible

    BusyIndicator {
        anchors.centerIn: parent
        visible: root.loading
        running: root.loading
        platformStyle: BusyIndicatorStyle { size: "large" }
    }
}
