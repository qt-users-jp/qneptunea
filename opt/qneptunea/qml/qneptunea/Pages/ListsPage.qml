import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: screen_name ? '@' + screen_name: ''
    busy: model.loading

    ListListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: ListsAllModel { id: model; user_id: root.id_str }
        onShowDetail: pageStack.push(listStatusesPage, {'id_str': detail.id_str, 'screen_name': detail.user.screen_name})
    }

//    Menu {
//        id: menu
//        visualParent: view
//        MenuLayout {
//            MenuItemWithIcon {
//                iconSource: 'image://theme/icon-m-toolbar-add'.concat(theme.inverted ? "-white" : "")
//                text: qsTr('Create')
//                onClicked: pageStack.push(listDetailPage)
//            }
//        }
//    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(screen_name).concat('&size=bigger')
            shortcutUrl: 'lists://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            enabled: false
//            enabled: root.id_str == oauth.user_id
            opacity: enabled ? 1.0 : 0.5
//            onClicked: {
//                if (menu.status == DialogStatus.Closed)
//                    menu.open()
//                else
//                    menu.close()
//            }
        }
//        onClosing: menu.close()
    }
}
