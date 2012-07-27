import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('Menu')

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
                width: parent.width
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
                        source: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(verifyCredentials.screen_name).concat('&size=bigger')
                        _id: verifyCredentials.profile_image_url
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
                        text: '@'.concat(verifyCredentials.screen_name)
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.nameColor
                    }
                }
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
                        text: verifyCredentials.statuses_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(userTimelinePage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }
                Button {
                    width: parent.buttonWidth
                    text: 'Favourites'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: verifyCredentials.favourites_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(favouritesPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'Following'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: verifyCredentials.friends_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(followingPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }
                Button {
                    width: parent.buttonWidth
                    text: 'Followers'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: verifyCredentials.followers_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(followersPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'Listed'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: verifyCredentials.listed_count
                        platformStyle: LabelStyle { fontPixelSize: constants.fontLSmall }
                    }
                    onClicked: pageStack.push(listedPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }

                Button {
                    width: parent.buttonWidth
                    text: 'List'
                    platformStyle: ButtonStyle { horizontalAlignment: Text.AlignLeft; fontPixelSize: constants.fontLarge }
                    onClicked: pageStack.push(listsPage, {'id_str': verifyCredentials.id_str, 'screen_name': verifyCredentials.screen_name})
                }
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-toolbar-alarm'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Trend')

                onClicked: pageStack.push(trendPage)
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-toolbar-contact'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Suggestions')

                onClicked: pageStack.push(slugPage)
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-common-location'.concat(theme.inverted ? "-inverse" : "")
                text: qsTr('Near by')

                onClicked: pageStack.push(nearByPage)
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-toolbar-settings'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Settings')

                onClicked: pageStack.push(settingsPage)
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-toolbar-tag'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Legal')

                onClicked: pageStack.push(legalPage)
            }
            AbstractListDelegate {
                width: parent.width
                height: constants.fontLarge * 3
                icon: 'image://theme/icon-m-toolbar-application'.concat(theme.inverted ? "-white" : "")
                text: qsTr('About')

                onClicked: pageStack.push(aboutPage)
            }

            Repeater {
                model: savedSearchesModel
                delegate: AbstractListDelegate {
                    width: viewport.width
                    height: constants.fontLarge * 3
                    icon: 'image://theme/icon-m-toolbar-search'.concat(theme.inverted ? "-white" : "")
                    text: model.name
                    separatorVisible: index < savedSearchesModel.size - 1

                    onClicked: pageStack.push(searchPage, {'id_str': model.name})
                }
            }
        }

        ScrollBar {
            anchors.top: parent.top
            anchors.right: parent.right
            height: flickable.height * flickable.contentY / (flickable.contentHeight - flickable.height)
//            onHeightChanged: console.debug(height, flickable.contentY, flickable.contentHeight, flickable.height)
        }
    }


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
