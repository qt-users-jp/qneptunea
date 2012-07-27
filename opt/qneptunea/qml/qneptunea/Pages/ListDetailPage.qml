import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: list.name ? list.name : qsTr('Create')
    busy: list.loading

    List { id: list; id_str: root.id_str }

    Column {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        Text {
            text: qsTr('Name')
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            color: constants.textColor
        }
        TextField {
            id: name
            text: list.name ? list.name : ''
            width: parent.width
        }
        Text {
            text: qsTr('Description')
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            color: constants.textColor
        }
        TextArea {
            id: description
            text: list.description ? list.description : ''
            width: parent.width
        }
        ButtonRow {
            RadioButton {
                id: modePublic
                text: qsTr('Public')
                checked: list.mode ? list.mode == 'public' : true
            }
            RadioButton {
                id: modePrivate
                text: qsTr('Private')
                checked: list.mode ? list.mode == 'private' : false
            }
        }
    }

    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-add'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Create')
                enabled: false
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 3}
        ToolIcon {
            platformIconId: 'toolbar-done'
            onClicked: {
                if (list.id_str.length == 0) {
                    list.createList({'name': name.text, 'description': description.text, 'mode': modePublic.checked ? 'public' : 'private' })
                } else {
                    list.updateList({'list_id': list.id_str, 'name': name.text, 'description': description.text, 'mode': modePublic.checked ? 'public' : 'private' })
                }
            }
        }
    }
}
