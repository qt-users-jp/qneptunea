import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Button {
    id: root
    height: constants.fontDefault + 40
    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontDefault }

    property alias numberVisible: counter.visible
    property alias number: counter.value

    CountBubble {
        id: counter
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -5
        largeSized: true
        scale: value > 0 ? 1.0 : 0.0
        visible: scale > 0
        Behavior on scale { NumberAnimation{duration: 1000; easing.type: Easing.OutElastic} }
    }
}
