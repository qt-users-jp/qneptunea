import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import QNeptunea 1.0

AbstractPage {
    id: root

    property variant linkMenu: null
    property alias visualParent: menu.visualParent
    property StateGroup currentPlugin
    currentPluginLoading: currentPlugin ? currentPlugin.loading : false

    function message(text, icon) {
        infoBanners.message({'iconSource': icon, 'text': text})
    }

    Timer {
        running: typeof currentPlugin === 'object' && currentPlugin !== null && !currentPlugin.loading
        repeat: false
        interval: 10
        onTriggered: {
            var text = root.currentPlugin.message
            var icon = root.currentPlugin.icon
            if (text.length > 0)
                infoBanners.message({'text': text, 'iconSource': icon})
            root.currentPlugin = null
        }
    }

    signal headerClicked()

    User {
        id: userToOpen
        onIdStrChanged: {
            if (id_str.length > 0)
                pageStack.push(userPage, {'id_str': userToOpen.id_str})
        }
    }
    StateGroup {
        states: [
            State {
                when: userToOpen.loading
                PropertyChanges {
                    target: root
                    running: true
                }
            }
        ]
    }

    function openLink(link, parameters) {
        console.debug(link)
        switch (true) {
        case /^search:\/\//.test(link):
            pageStack.push(searchPage, {'id_str': link.substring(9)})
            break
        case /^user:\/\//.test(link):
            pageStack.push(userPage, {'id_str': link.substring(7)})
            break
        case /^status:\/\//.test(link):
            pageStack.push(statusPage, {'id_str': link.substring(8)})
            break
        case /^https?:\/\/(mobile\.)?twitter\.com\/[a-zA-z0-9_]+\/status\/([0-9]+)$/.test(link):
            pageStack.push(statusPage, {'id_str': RegExp.$2})
            break
        case /^https?:\/\/(mobile\.)?twitter\.com\/([a-zA-z0-9_]+)$/.test(link):
            if (userToOpen.screen_name === RegExp.$2 && !userToOpen.loading && userToOpen.id_str.length > 0)
                pageStack.push(userPage, {'id_str': userToOpen.id_str})
            else
                userToOpen.screen_name = RegExp.$2
            break
        default:
            if (!root.linkMenu) {
                root.linkMenu = menu
                menu.link = link
                if (typeof parameters === 'undefined')
                    parameters = {'openLink': true }
                else
                    parameters.openLink = true
                menu.parameters = parameters
                menu.open()
            }
            break
        }
    }

    Menu {
        id: menu
        property url link
        property variant parameters

        MenuLayout {
            id: layout
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-l-browser-main-view'
                text: qsTr('Open in the browser')
                onClicked: {
                    root.running = true
                    Qt.openUrlExternally(menu.link)
                }
                Component.onCompleted: console.debug('parent0', parent)
            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-application'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Open in the default app')
                onClicked: {
                    root.running = true
                    ActionHandler.openUrlExternally(menu.link)
                }
            }

            Repeater {
                model: servicePlugins.pluginInfo
                delegate: MenuItemWithIcon {
                    id: customItem
                    iconSource: model.plugin.icon
                    text: model.plugin.service
                    visible: model.plugin.matches(menu.link)
                    onClicked: {
                        root.currentPlugin = plugin
                        model.plugin.open(menu.link, menu.parameters)
                    }
                }
            }
        }
        property bool __completed: false
        onStatusChanged: {
            if (menu.__completed && menu.status === DialogStatus.Closed) {
                root.linkMenu = null
            }
        }
        Component.onCompleted: menu.__completed = true
    }
}
