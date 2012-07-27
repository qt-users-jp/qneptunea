import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    id: root
    property bool backOnly: false

    signal closing()
    ToolIcon {
        platformIconId: "toolbar-back"
        onClicked: {
            root.closing()
            pageStack.pop()
        }
    }
    ToolIcon {
        platformIconId: "toolbar-home"
        visible: !root.backOnly
        onClicked: {
            root.closing()
            pageStack.pop(mainPage)
        }
    }
}
