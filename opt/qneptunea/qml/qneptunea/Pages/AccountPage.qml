import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../Views'
import '../Delegates'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Account')
    busy: verifyCredentials.loading || updateProfile.loading || settings.loading

    property bool selectingMedia: false

    onStatusChanged: {
        if (root.status === PageStatus.Active) {
            if (selectingMedia) {
                if (mediaSelected !== undefined) {
                    profile_image.source = mediaSelected
                    mediaSelected = undefined
                }
                selectingMedia = false
            }
        }
    }

    UpdateProfile {
        id: updateProfile
        name: name.text
        url: url.text
        location: location.text
        description: description.text

        onLoadingChanged: if (!loading) pageStack.pop()
    }

    Settings {
        id: settings
    }

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        contentHeight: profilePane.height
        clip: true

        Item {
            id: profilePane
            width: parent.width
            height: detailArea.y + detailArea.height + 10 + 2

            Item {
                id: userArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(iconArea.height, nameArea.height) + constants.listViewScrollbarWidth * 2
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

                        MouseArea {
                            anchors.fill: parent
                            enabled: !header.busy
                            onClicked: {
                                root.selectingMedia = true
                                mediaSelected = undefined
                                pageStack.push(selectMediaPage)
                            }
                        }
                    }
                }

                Column {
                    id: nameArea
                    anchors.left: iconArea.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.leftMargin: constants.listViewMargins

                    TextField {
                        id: name
                        width: parent.width
                        enabled: !header.busy
                        text: verifyCredentials.name
                        maximumLength: 20
                        platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontLarge }
                        platformSipAttributes: SipAttributes {
                            actionKeyLabel: 'Next'
                        }
                        Keys.onReturnPressed: location.forceActiveFocus()
                    }

                    Text {
                        text: verifyCredentials.screen_name ? '@' + verifyCredentials.screen_name : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.nameColor
                    }
                }
            }

            Column {
                id: detailArea
                anchors.top: userArea.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: constants.listViewMargins

                Text {
                    text: qsTr('Bio')
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                TextArea {
                    id: description
                    width: parent.width
                    enabled: !header.busy
                    text: verifyCredentials.description
                    platformStyle: TextAreaStyle { textFont.pixelSize: constants.fontLarge }
                }

                Text {
                    text: qsTr('Location')
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                TextField {
                    id: location
                    width: parent.width
                    enabled: !header.busy
                    text: verifyCredentials.location
                    maximumLength: 30
                    platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                    platformSipAttributes: SipAttributes {
                        actionKeyLabel: 'Next'
                    }
                    Keys.onReturnPressed: url.forceActiveFocus()
                }

                Text {
                    text: qsTr('Website')
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                TextField {
                    id: url
                    width: parent.width
                    enabled: !header.busy
                    text: verifyCredentials.url
                    maximumLength: 100
                    platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                    platformSipAttributes: SipAttributes {
                        actionKeyLabel: 'Next'
                    }
                    Keys.onReturnPressed: description.forceActiveFocus();
                }
                Button {
                    id: profileUpdate
                    anchors.right: parent.right
                    enabled: !verifyCredentials.loading && !updateProfile.loading
                    checked: true
                    text: qsTr('Update')
                    platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                    onClicked: updateProfile.exec()
                }
                Item {
                    width: parent.width
                    height: 15
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: constants.separatorHeight
                        color: constants.separatorNormalColor
                        opacity: constants.separatorOpacity
                    }
                }
            }
        }

        Column {
            id: settingsPane
            width: parent.width
            spacing: 4

            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'always_use_https'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.always_use_https
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'discoverable_by_email'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.discoverable_by_email
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'geo_enabled'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.geo_enabled
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'language'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.language
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'protected'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings._protected
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'screen_name'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.screen_name
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'show_all_inline_media'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.show_all_inline_media
            }

            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'sleep_time'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.sleep_time.enabled
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.sleep_time.start_time
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.sleep_time.end_type
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'time_zone'
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.time_zone.name
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: settings.time_zone.utc_offset
            }
            Label {
                platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
                text: 'trend_location' + settings.trend_location.length
            }

            Repeater {
                model: settings.trend_location
                Column {
                    width: settingsPane.width
                    spacing: 4

                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].country
                        text: modelData.country
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].countryCode
                        text: modelData.countryCode
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].name
                        text: modelData.name
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].parentid
                        text: modelData.parentid
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].placeType.code
                        text: modelData.placeType.code
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].placeType.name
                        text: modelData.placeType.name
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].url
                        text: modelData.url
                    }
                    Label {
                        platformStyle: LabelStyle { fontPixelSize: constants.fontDefault }
//                        text: settings.trend_location[index].woeid
                        text: modelData.woeid
                    }
                }
            }
        }
    }

    Menu {
        id: menu
        visualParent: container
        MenuLayout {
            MenuItemWithIcon {
                iconSource: 'image://theme/icon-m-toolbar-update'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Sign out')
                onClicked: {
                    oauth.unauthorize()
                    pageStack.pop(mainPage)
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
            ToolSpacer {}

            ToolIcon {
                id: showProfile
                platformIconId: "toolbar-contact"
                enabled: !header.busy
                opacity: enabled ? 1.0 : 0.5
                onClicked: root.state = 'profile'
            }

            ToolIcon {
                id: showSettings
                platformIconId: "toolbar-settings"
                enabled: !header.busy
                opacity: enabled ? 1.0 : 0.5
                onClicked: root.state = 'settings'
            }

            ToolIcon {
                platformIconId: "toolbar-view-menu"
                onClicked: {
                    if (menu.status == DialogStatus.Closed)
                        menu.open()
                    else
                        menu.close()
                }
            }
        }

    state: 'profile'
    states: [
        State {
            name: 'profile'
            PropertyChanges {
                target: container
                contentHeight: profilePane.height
            }
            PropertyChanges {
                target: settingsPane
                opacity: 0
            }
            PropertyChanges {
                target: showProfile
                enabled: false
            }
        },
        State {
            name: 'settings'
            PropertyChanges {
                target: container
                contentHeight: settingsPane.height
            }
            PropertyChanges {
                target: profilePane
                opacity: 0
            }
            PropertyChanges {
                target: showSettings
                enabled: false
            }
        }

    ]
    transitions: [
        Transition {
            from: "profile"
            to: "settings"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "settings"
            to: "profile"
            NumberAnimation { properties: 'opacity' }
        }
    ]
}
