/* Copyright (c) 2012-2013 QNeptunea Project.
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
import Twitter4QML 1.1
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('QNeptunea for N9 %1').arg(currentVersion.version)
    busy: verifyCredentials.loading || listsModel.loading

    property alias editing: shortcuts.editing

    Flickable {
        id: flickable
        anchors { top: parent.top; topMargin: root.headerHeight; left: parent.left; right: parent.right; bottom: searchButton.top }
        contentHeight: viewport.height
        clip: true
        Column {
            id: viewport
            width: parent.width

            Item {
                id: userArea
                anchors.left: parent.left
                anchors.leftMargin: constants.listViewMargins
                anchors.right: parent.right
                anchors.rightMargin: constants.listViewMargins
                height: Math.max(iconArea.height, nameArea.height) + 12
                Item {
                    id: iconArea
                    anchors.left: parent.left
                    anchors.leftMargin: constants.iconLeftMargin
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    width: 73
                    height: width

                    ProfileImage {
                        anchors.fill: parent
                        source: to_s(verifyCredentials.profile_image_url).replace('_normal', '_bigger')
                        _id: source
                    }
                }

                Column {
                    id: nameArea
                    anchors.left: iconArea.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.leftMargin: constants.listViewMargins

                    Text {
                        text: verifyCredentials.name
                        font.bold: true
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontLarge
                        color: constants.nameColor
                    }
                    Text {
                        text: '@%1'.arg(verifyCredentials.screen_name)
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.nameColor
                    }
                }
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
                    number: verifyCredentials.loading ? -1 : verifyCredentials.statuses_count
                    onClicked: pageStack.push(userTimelinePage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Favourites')
                    number: verifyCredentials.loading ? -1 : verifyCredentials.favourites_count
                    onClicked: pageStack.push(favouritesPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Following')
                    number: verifyCredentials.loading ? -1 : verifyCredentials.friends_count
                    onClicked: pageStack.push(followingPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Followers')
                    number: verifyCredentials.loading ? -1 : verifyCredentials.followers_count
                    onClicked: pageStack.push(followersPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('Listed')
                    number: verifyCredentials.loading ? -1 : verifyCredentials.listed_count
                    onClicked: pageStack.push(listedPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})
                }

                ButtonWithNumber {
                    width: parent.buttonWidth
                    text: qsTr('List')
                    number: listsModel.loading ? -1 : listsModel.size
                    onClicked: pageStack.push(listsPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name, 'profile_image_url': verifyCredentials.profile_image_url})

                    ListsModel {
                        id: listsModel
                        user_id: verifyCredentials.id_str

                        onRateLimitExceeded: {
                            infoBanners.rateLimitMessage(xrlLimit, xrlRemaining, xrlReset)
                        }
                    }
                }
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-alarm'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Trend')

                onClicked: pageStack.push(trendPage)
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-contact'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Suggestions')

                onClicked: pageStack.push(slugPage)
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-common-location'.concat(theme.inverted ? "-inverse" : "")
                text: qsTr('Near by')
                opacity: constants.locationDataDisabled ? 0.5 : 1.0

                onClicked: {
                    if (constants.locationDataDisabled) {
                        pageStack.push(settingsPage, {'currentTab': 'misc'})
                    } else {
                        pageStack.push(nearByPage)
                    }
                }
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-settings'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Settings')

                onClicked: pageStack.push(settingsPage)
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-tag'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Legal')

                onClicked: pageStack.push(legalPage)
            }
            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-application'.concat(theme.inverted ? "-white" : "")
                text: qsTr('About')

                onClicked: pageStack.push(aboutPage)
            }

            Repeater {
                model: savedSearchesModel
                delegate: AbstractListDelegate {
                    width: viewport.width
                    icon: 'image://theme/icon-m-toolbar-search'.concat(theme.inverted ? "-white" : "")
                    text: model.name

                    onClicked: pageStack.push(searchPage, {'id_str': model.name})
                }
            }

            AbstractListDelegate {
                width: parent.width
                icon: 'image://theme/icon-m-toolbar-volume-off'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Mute')
                onClicked: pageStack.push(mutePage, {})
            }
        }

    }
    ScrollBar { target: flickable }


    TextField {
        id: searchTerm
        anchors { left: parent.left; right: searchButton.left; verticalCenter: searchButton.verticalCenter }
        readOnly: root.editing
        placeholderText: qsTr('Search / @people')
        platformSipAttributes: SipAttributes {
            actionKeyLabel: 'Search'
            actionKeyEnabled: searchTerm.text.length > 0
        }
        platformStyle: TextFieldStyle { paddingRight: clearButton.width }
        Image {
            id: clearButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/icon-m-input-clear"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    inputContext.reset();
                    searchTerm.text = '';
                }
            }
        }
        Keys.onReturnPressed: searchButton.search()
    }

    ToolIcon {
        id: searchButton
        anchors { bottom: shortcuts.top; right: parent.right }
        enabled: searchTerm.text.length > 0 && !root.editing
        platformIconId: "toolbar-search"
        onClicked: search()
        function search() {
            searchButton.forceActiveFocus()
            if (searchTerm.text.charAt(0) == '@') {
                pageStack.push(searchUsersPage, {'id_str': searchTerm.text})
            } else {
                pageStack.push(searchPage, {'id_str': searchTerm.text})
            }
        }
    }

    Shortcuts {
        id: shortcuts
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: shortcutModel.count > 0 ? 80 : 0
        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        z: 1
    }

    onStatusChanged: {
        if (root.status !== PageStatus.Active) {
            shortcuts.editing = false
        }
    }
}
