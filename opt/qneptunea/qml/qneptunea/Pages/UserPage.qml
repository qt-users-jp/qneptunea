/* Copyright (c) 2012 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractLinkPage {
    id: root

    screen_name: user.screen_name
    title: to_s(screen_name, '@%1')
    busy: user.loading || listsAllModel.loading
    visualParent: flickable

    User {
        id: user
        id_str: root.id_str
        onFollowingChanged: {
            if (window.friends.length === 0) return

            var friends = window.friends
            if (following) {
                friends.push(user.id_str)
            } else if (friends.indexOf(user.id_str) > -1) {
                friends.splice(friends.indexOf(user.id_str), 1)
            }
            window.friends = friends
        }
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
        interactive: !defined(root.linkMenu)

        Column {
            id: container
            width: parent.width

            UserDetailDelegate {
                id: delegate
                width: parent.width
                user: user
                followsYou: defined(showFriendships.relationship.target) && showFriendships.relationship.target.following
                onAvatarClicked: {
                    pageStack.push(imagePreviewPage, {'type': 'image', url: 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=original'.arg(user.screen_name)})
                }

                onLinkActivated: root.openLink(link)
            }
            Flow {
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewMargins
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewMargins
                spacing: constants.listViewMargins
                property int columns: window.inPortrait ? 2 : 3
                property int buttonWidth: (width - constants.listViewMargins * columns) / columns

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Tweets')
                    number: user.statuses_count
                    onClicked: pageStack.push(userTimelinePage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Favourites')
                    number: user.favourites_count
                    onClicked: pageStack.push(favouritesPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Following')
                    number: user.friends_count
                    onClicked: pageStack.push(followingPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Followers')
                    number: user.followers_count
                    onClicked: pageStack.push(followersPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Listed')
                    number: user.listed_count
                    onClicked: pageStack.push(listedPage, {'id_str': user.id_str, 'screen_name': user.screen_name})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('List')
                    number: listsAllModel.size
                    onClicked: pageStack.push(listsPage, {'id_str': user.id_str, 'screen_name': user.screen_name})

                    ListsAllModel { id: listsAllModel; user_id: user.id_str }
                }
            }
        }
    }

    Menu {
        id: menu
        visualParent: flickable
        MenuLayout {
            MenuItemWithIcon {
                property bool muted: window.filters.indexOf('@%1'.arg(user.screen_name)) > -1
                iconSource: 'image://theme/icon-m-toolbar-volume'.concat(muted ? '' : '-off').concat(theme.inverted ? "-white" : "")
                text: muted ? qsTr('Unmute @%1').arg(user.screen_name) : qsTr('Mute @%1').arg(user.screen_name)
                onClicked: {
                    var filters = window.filters
                    if (muted) {
                        var index = filters.indexOf('@%1'.arg(user.screen_name))
                        while (index > -1) {
                            filters.splice(index, 1)
                            index = filters.indexOf('@%1'.arg(user.screen_name))
                        }
                    } else {
                        filters.unshift('@'.concat(user.screen_name))
                    }
                    window.filters = filters
                }
            }
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
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name=%1&size=bigger'.arg(screen_name)
            shortcutUrl: 'user://%1/%2'.arg(id_str).arg(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            opacity: enabled ? 1.0 : 0.5
            enabled: root.linkMenu !== null || root.id_str !== oauth.user_id
            onClicked: {
                if (root.linkMenu) {
                    root.linkMenu.close()
                } else {
                    if (menu.status === DialogStatus.Closed)
                        menu.open()
                    else
                        menu.close()
                }
            }
        }
        onClosing: menu.close()
    }
}
