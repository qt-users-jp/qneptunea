import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../Views'
import '../QNeptunea/Components/'

Page {
    id: root

    Connections {
        target: app
        onOpenUrl: {
            console.debug(url.join(','))
            console.debug(url.length)
            for (var i = 0; i < url.length; i++) {
                var arr = url[i].split('/')
                console.debug('arr', arr)
                if (arr.shift() !== 'qneptunea:') continue
                arr.shift()
                var action = arr.shift()
                var parameters = arr
                console.debug('action', action)
                if (action == 'page') {
                    if (parameters[0] == 'mentions') {
                        mentionsButton.checked = true
                        mentionsButton.clicked()
                        mentions.moveToTop()
                    } else if (parameters[0] == 'messages') {
                        directMessageButton.checked = true
                        directMessageButton.clicked()
                        directMessage.moveToTop()
                    } else if (parameters[0] == 'searches') {
                        savedSearchesButton.checked = true
                        savedSearchesButton.clicked()
                        savedSearches.moveToTop()
                    } else {
                        console.debug('unknown parameters', parameters)
                    }
                } else if (action == 'status') {
                    pageStack.push(statusPage, {'id_str': parameters[0]})
                } else if (action == 'directmessage') {
                    pageStack.push(directMessagePage, {'id_str': parameters[0]})
                } else if (action == 'user') {
                    pageStack.push(userPage, {'id_str': parameters[0]})
                }
//                infoBanners.message(url[i])
            }

        }
    }

    Timer {
        running: root.status == PageStatus.Active && oauth.state !== OAuth.Authorized
        interval: 100
        onTriggered: pageStack.push(authorizationPage)
    }

    TabGroup {
        id: tabGroup
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusBar.top

        currentTab: home

        property bool active: root.status === PageStatus.Active && platformWindow.viewMode === WindowState.Fullsize && platformWindow.visible && platformWindow.active
        HomePage { id: home; pageStack: root.pageStack; active: tabGroup.currentTab === home && tabGroup.active }
        MentionsPage { id: mentions; pageStack: root.pageStack; active: tabGroup.currentTab === mentions && tabGroup.active }
        DirectMessagesPage { id: directMessage; pageStack: root.pageStack; active: tabGroup.currentTab === directMessage && tabGroup.active }
        SavedSearchStreamPage { id: savedSearches; pageStack: root.pageStack; active: tabGroup.currentTab === savedSearches && tabGroup.active }
        MainMenuPage { id: menu; pageStack: root.pageStack }
    }

    ToolBar {
        id: statusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        tools: ToolBarLayout {
            ToolIcon {
                platformIconId: "toolbar-new-email"
                opacity: enabled ? 1.0 : 0.5
                onClicked: pageStack.push(tweetPage)
            }

            ButtonRow {
                TabButton {
                    id: homeButton
                    iconSource: 'image://theme/icon-m-toolbar-home'.concat(theme.inverted ? "-white" : "")
                    tab: home
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (homeButton.checked) {
                                home.moveToTop()
                            } else {
                                homeButton.privatePressed()
                            }
                        }
                    }


                    CountBubble {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -5
                        value: home.unreadCount
                        largeSized: true
                        scale: value > 0 && !loadedTimer.running ? 1.0 : 0.0
                        visible: scale > 0
                        Behavior on scale { NumberAnimation{duration: 1000; easing.type: Easing.OutElastic} }
                    }
                }

                TabButton {
                    id: mentionsButton
                    iconSource: '../images/mentions'.concat(theme.inverted ? '-white.png' : '.png')
                    tab: mentions
                    enabled: mentions.opacity == 1
                    opacity: enabled ? 1 : 0.5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (mentionsButton.checked) {
                                mentions.moveToTop()
                            } else {
                                mentionsButton.privatePressed()
                            }
                        }
                    }

                    CountBubble {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -5
                        value: mentions.unreadCount
                        largeSized: true
                        scale: value > 0 && mentionsButton.enabled ? 1.0 : 0.0
                        visible: scale > 0
                        Behavior on scale { NumberAnimation{duration: 1000; easing.type: Easing.OutElastic} }
                    }
                }
                TabButton {
                    id: directMessageButton
                    iconSource: '../images/dm'.concat(theme.inverted ? '-white.png' : '.png')
                    tab: directMessage
                    enabled: directMessage.opacity == 1
                    opacity: enabled ? 1 : 0.5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (directMessageButton.checked) {
                                directMessage.moveToTop()
                            } else {
                                directMessageButton.privatePressed()
                            }
                        }
                    }

                    CountBubble {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -5
                        value: directMessage.unreadCount
                        largeSized: true
                        scale: value > 0 && directMessageButton.enabled ? 1.0 : 0.0
                        visible: scale > 0
                        Behavior on scale { NumberAnimation{duration: 1000; easing.type: Easing.OutElastic} }
                    }
                }
                TabButton {
                    id: savedSearchesButton
                    iconSource: 'image://theme/icon-m-toolbar-frequent-used'.concat(theme.inverted ? "-white" : "")
                    tab: savedSearches
                    enabled: savedSearches.opacity == 1
                    opacity: enabled ? 1 : 0.5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (savedSearchesButton.checked) {
                                savedSearches.moveToTop()
                            } else {
                                savedSearchesButton.privatePressed()
                            }
                        }
                    }

                    CountBubble {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -5
                        value: savedSearches.unreadCount
                        largeSized: true
                        scale: value > 0 && savedSearchesButton.enabled ? 1.0 : 0.0
                        visible: scale > 0
                        Behavior on scale { NumberAnimation{duration: 1000; easing.type: Easing.OutElastic} }
                    }
                }
                TabButton {
                    id: menuButton
                    iconSource: 'image://theme/icon-m-toolbar-view-menu'.concat(theme.inverted ? "-white" : "")
                    tab: menu

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (menuButton.checked) {
                                if (menu.editing) {
                                    menu.editing = false
                                }
                            } else {
                                menuButton.privatePressed()
                            }
                        }
                        onPressAndHold: {
                            if (menuButton.checked) {
                                menu.editing = !menu.editing
                            } else {
                                menuButton.privatePressed()
                            }
                        }
                    }

                    states: [
                        State {
                            name: 'editing'
                            when: menu.editing
                            PropertyChanges {
                                target: menuButton
                                iconSource: 'image://theme/icon-m-toolbar-done'.concat(theme.inverted ? "-white" : "")
                            }
                        }
                    ]
                }
            }
        }
    }

    Connections {
        target: window
        onShortcutAddedChanged: {
            if (shortcutAdded && !menuButton.checked) {
                menuButton.privatePressed()
            }
            window.shortcutAdded = false
        }
    }
}
