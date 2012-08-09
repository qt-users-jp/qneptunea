import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('Mute Settings')

    Flickable {
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        contentHeight: filters.height
        clip: true
        TextArea {
            id: filters
            width: parent.width
            placeholderText: qsTr('@selop\n#Lumia\nhttp://nokia.ly/\nHTML5\n...')
            text: window.filters.join('\n')
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolButtonRow {
            ToolButton {
                id: button

                checked: enabled
                text: qsTr('Save')

                function save() {
                    root.busy = true
                    window.filters = filters.text.split(/\n/)
                    pageStack.pop()
                    root.busy = true
                }

                onClicked: save()
            }
        }
        ToolSpacer {}
//        ToolIcon {
//            platformIconId: "toolbar-view-menu"
//            enabled: typeof root.linkMenu !== 'undefined'
//            opacity: enabled ? 1.0 : 0.5
//            onClicked: {
//                root.linkMenu.close()
//            }
//        }
    }
}
