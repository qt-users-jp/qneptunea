import QtQuick 1.1
import com.nokia.meego 1.0

ToolIcon {
    id: root

    property string shortcutIcon
    property string shortcutUrl: 'page://'
    property int shortcutIndex: -1

    iconSource: 'image://theme/icon-m-toolbar-attachment'.concat(theme.inverted ? "-white" : "")

    opacity: enabled ? 1.0 : 0.5
    onClicked: {
        if (root.linkMenu) root.linkMenu.close()
        if (root.shortcutIndex < 0) {
            var gridId = -1
            for (var i = 0; i < shortcutModel.count; i++) {
                gridId = Math.max(gridId, shortcutModel.get(i).gridId)
            }

            shortcutModel.append({'icon': root.shortcutIcon, 'link': root.shortcutUrl, 'gridId': gridId + 1})
            window.shortcutAdded = true
            root.parent.closing()
            pageStack.pop(mainPage)
        } else {
            shortcutModel.remove(root.shortcutIndex)
        }
        root.checkIndex()
    }

    states: [
        State {
            name: 'added'
            when: root.shortcutIndex > -1
            PropertyChanges {
                target: root
                iconSource: 'image://theme/icon-m-toolbar-attachment'.concat(theme.inverted ? "-white-selected" : "-selected")
            }
        },
        State {
            when: shortcutModel.count == 6
            PropertyChanges { target: root; enabled: false }
        }
    ]
    Component.onCompleted: checkIndex()

    function checkIndex() {
        root.shortcutIndex = -1
        for (var i = 0; i < shortcutModel.count; i++) {
            if (shortcutModel.get(i).link == shortcutUrl) {
                root.shortcutIndex = i
                break
            }
        }
    }
}
