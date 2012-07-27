import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractLinkPage {
    id: root

    screen_name: user.screen_name
    title: screen_name ? '@' + screen_name : ''
    busy: user.loading
    visualParent: flickable

    User {
        id: user
        id_str: root.id_str
    }

    ShowFriendships {
        id: showFriendships
        source_id: oauth.user_id
        target_id: root.id_str
    }

    Flickable {
        id: flickable
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentWidth: width
        contentHeight: container.height
        clip: true
        interactive: typeof root.linkMenu === 'undefined'

        Column {
            id: container
            width: parent.width

            UserDetailDelegate {
                id: delegate
                width: parent.width
                user: user
                followsYou: typeof showFriendships.relationship.target !== 'undefined' && showFriendships.relationship.target.following
                onAvatarClicked: {
                    pageStack.push(previewPage, {'type': 'image', url: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=original')})
                }

                onLinkActivated: root.openLink(link)
            }
            Flow {
                width: parent.width
                spacing: constants.listViewMargins
                property int columns: window.inPortrait ? 2 : 3
                property int buttonWidth: (width - constants.listViewMargins * columns) / columns
                Button {
                    width: parent.buttonWidth
                    text: 'Tweets'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: user.statuses_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(userTimelinePage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }
                Button {
                    width: parent.buttonWidth
                    text: 'Favourites'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: user.favourites_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(favouritesPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'Following'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: user.friends_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(followingPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }
                Button {
                    width: parent.buttonWidth
                    text: 'Followers'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: user.followers_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(followersPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'Listed'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: user.listed_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(listedPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'List'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    onClicked: pageStack.push(listsPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }
            }
        }
    }

    Menu {
        id: menu
        visualParent: flickable
        MenuLayout {
//            MenuItemWithIcon {
//                id: translation
//                iconSource: 'image://theme/icon-m-toolbar-select-text'.concat(enabled ? "" : "-dimmed").concat(theme.inverted ? "-white" : "")
//                text: qsTr('Translate')
//                onClicked: delegate.translate()
//            }
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-favorite-'.concat(user.following ? 'mark' : 'unmark').concat(theme.inverted ? "-white" : "")
                text: user.following ? qsTr('Unfollow @%1').arg(user.screen_name) : qsTr('Follow @%1').arg(user.screen_name)
                onClicked: {
                    if (user.following)
                        user.unfollow()
                    else
                        user.follow()
                }
            }

            MenuItem {
                text: user.blocking ? qsTr('Unblock @%1').arg(user.screen_name) : qsTr('Block @%1').arg(user.screen_name)
                onClicked: {
                    if (user.blocking)
                        user.unblock()
                    else
                        user.block()
                }
            }

            MenuItem {
                text: qsTr('Report @%1 for spam').arg(user.screen_name)
                onClicked: user.reportForSpam()
            }
        }
    }
    Connections {
        target: menu
        onStatusChanged: root.linkMenu = (menu.status == DialogStatus.Closed ? undefined : menu)
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolIcon {
            iconSource: '../images/mentions'.concat(theme.inverted ? '-white.png' : '.png')
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                root.pageStack.push(tweetPage, {'statusText': '@' + user.screen_name + ' '})
            }
        }
        ToolIcon {
            iconSource: '../images/dm'.concat(theme.inverted ? '-white.png' : '.png')
            opacity: enabled ? 1.0 : 0.5
            enabled: delegate.followsYou
            onClicked: {
                if (root.linkMenu) root.linkMenu.close()
                menu.close()
                root.pageStack.push(sendDirectMessagePage, {'recipient': user})
            }
        }
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(screen_name).concat('&size=bigger')
            shortcutUrl: 'user://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            opacity: enabled ? 1.0 : 0.5
            enabled: root.linkMenu !== null || root.id_str !== oauth.user_id
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
        onClosing: menu.close()
    }
}
