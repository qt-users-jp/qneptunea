import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../Views'
import '../Delegates'
import '../QNeptunea/Components/'

AbstractLinkPage {
    id: root

    title: qsTr('DirectMessage')
    busy: direct_message.loading
    visualParent: container

    DirectMessage {
        id: direct_message
        id_str: root.id_str
        onIdStrChanged: {
            if (id_str.length == 0 && root.status == PageStatus.Active)
                pageStack.pop()
        }
    }

    Item {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        DirectMessageDetailDelegate {
            id: delegate
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            item: direct_message
            sender: direct_message.sender
            recipient: direct_message.recipient
            onLinkActivated: root.openLink(link)
            onUserClicked: pageStack.push(userPage, {'id_str': user.id_str})

            Behavior on height {
                NumberAnimation {}
            }
        }
    }

    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            MenuItemWithIcon {
                id: copy
                iconSource: 'image://theme/icon-m-toolbar-tag'.concat(enabled ? "" : "-dimmed").concat(theme.inverted ? "-white" : "")
                text: qsTr('Copy to clipboard')
                onClicked: {
                    clipboard.text = direct_message.text
                    clipboard.selectAll()
                    clipboard.cut()
                }
            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-delete'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Delete')
                onClicked: direct_message.destroyDirectMessage()
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {}

        ToolIcon {
            platformIconId: "toolbar-reply"
//            iconSource: '../images/mentions'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                var parameters = {}
                parameters['in_reply_to'] = direct_message.data
                if (direct_message.recipient_id == oauth.user_id) {
                    parameters['recipient'] = direct_message.sender
                } else {
                    parameters['recipient'] = direct_message.recipient
                }
                pageStack.push(sendDirectMessagePage, parameters)
            }
        }

        ToolSpacer {}

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                if (root.linkMenu) {
                    root.linkMenu.close()
                } else {
                    if (menu.status == DialogStatus.Closed)
                        menu.open()
                    else
                        menu.close()
                }
            }
        }
    }
}
