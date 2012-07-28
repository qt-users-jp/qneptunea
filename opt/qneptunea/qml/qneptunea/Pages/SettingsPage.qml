import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('Settings')

    StatusDelegate {
        id: delegate
        anchors.top: parent.top; anchors.topMargin: root.headerHeight
        anchors.left: parent.left
        anchors.right: parent.right

        UserTimelineModel { id: userTimeline; count: 1 }

        item: userTimeline.size > 0 ? userTimeline.get(0) : undefined
        user: userTimeline.size > 0 ? userTimeline.get(0).user : undefined
    }

    RetweetedByUserModel {
        id: qneptuneaTheme
        _id: 'QNeptuneaTheme'
        count: 200
        page: 1
        sortKey: 'id_str'
        property int lastSize: 0
        onLoadingChanged: {
            if (loading) return
            if (size == lastSize) {
                // read all data
                for (var i = 0; i < size; i++) {
                    themes.add(get(i))
                }
            } else {
                // load until last
                lastSize = size
                page++
                reload()
            }

        }
    }

    Timer {
        running: true
        interval: 10
        repeat: false
        onTriggered: {
            for (var i = 0; i < themePlugins.pluginInfo.count; i++) {
                themes.append(themePlugins.pluginInfo.get(i))
            }
        }
    }

    ListModel {
        id: themes

        function add(data) {
            if (data.retweeted_status.media.length !== 1) return
            if (data.retweeted_status.entities.urls.length !== 1) return

            var theme = data.retweeted_status
            var found = false
            for (var i = 0; i < count; i++) {
                if (get(i).vote < 0) continue
                if (get(i).vote < theme.retweet_count) {
                    insert(i, {'preview': theme.media[0], 'author': theme.user.screen_name, 'path': '.local/share/data/QNeptunea/QNeptunea/theme/'.concat(theme.id_str), 'description': theme.rich_text.replace(/<a .*?>.*?<\/a>/g, ''), 'vote': theme.retweet_count, 'voted': theme.retweeted, 'download': theme.entities.urls[0].expanded_url, 'source': theme})
                    found = true
                    break
                }
            }
            if (!found) {
                append({'preview': theme.media[0], 'author': theme.user.screen_name, 'path': '.local/share/data/QNeptunea/QNeptunea/theme/'.concat(theme.id_str), 'description': theme.rich_text.replace(/<a .*?>.*?<\/a>/g, ''), 'vote': theme.retweet_count, 'voted': theme.retweeted, 'download': theme.entities.urls[0].expanded_url, 'source': theme})
            }
        }
    }

    QueryDialog {
        id: signOutConfirmation
        icon: 'image://theme/icon-m-content-third-party-update'.concat(theme.inverted ? "-inverse" : "")
        titleText: qsTr('Sign out')
        message: qsTr('QNeptunea will be closed.')

        acceptButtonText: qsTr('Sign out')
        rejectButtonText: qsTr('Cancel')

        onAccepted: {
            oauth.unauthorize()
            Qt.quit()
        }
    }

    GridView {
        id: themeView
        anchors.top: delegate.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.footerHeight

        cellWidth: 160
        cellHeight: 160
        clip: true

        model: themes

        delegate: Image {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            source: model.preview
            fillMode: Image.PreserveAspectCrop
            smooth: true
            clip: true
            Text {
                anchors.centerIn: parent
                text: 'TBD'
                smooth: true
                rotation: -20
                font.pixelSize: 50
                font.bold: true
                style: Text.Outline
                styleColor: 'white'
                visible: typeof model.preview === 'undefined'
            }

            ProfileImage {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 48
                height: 48
                source: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(model.author).concat('&size=normal')
                smooth: true
            }

            CountBubble {
                id: retweets
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                value: typeof model.vote !== 'undefined' ? model.vote : 0
                largeSized: true
                visible: value > 0
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var parameters = {}
                    parameters.source = model.source
                    parameters.preview = model.preview
                    parameters.author = model.author
                    parameters.description = model.description
                    parameters.localPath = model.path
                    parameters.retweet_count = model.vote
                    parameters.retweeted = model.voted
//                    console.debug('typeof model.vote', typeof model.vote)
                    if (typeof model.vote === 'undefined') {
                    } else {
//                        console.debug('model.download', model.download)
                        parameters.remoteUrl = model.download
                    }
                    pageStack.push(themePage, parameters)
                }
            }
        }
    }

    Flickable {
        id: detailView
        anchors.top: delegate.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.footerHeight

        contentHeight: detailContainer.height
        clip: true

        Column {
            id: detailContainer
            width: parent.width
            spacing: 4

            Text {
                text: qsTr('Icon size:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: qsTr('Normal')
                    platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                    checked: constants.listViewIconSize == 48
                    onClicked: {
                        constants.listViewIconSize = 48
                        constants.listViewIconSizeName = 'normal'
                    }
                }
                Button {
                    text: qsTr('Bigger')
                    platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                    checked: constants.listViewIconSize == 73
                    onClicked: {
                        constants.listViewIconSize = 73
                        constants.listViewIconSizeName = 'bigger'
                    }
                }
            }

            Text {
                text: qsTr('Font size:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }
            Slider {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                minimumValue: 20
                maximumValue: 36
                value: constants.fontDefault
                onValueChanged: if (root.status === PageStatus.Active) constants.fontDefault = value
            }

            Text {
                text: qsTr('Separator opacity:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }
            Slider {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                value: constants.separatorOpacity
                onValueChanged: if (root.status === PageStatus.Active) constants.separatorOpacity = value
            }

            Text {
                text: qsTr('Streaming:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Row {
                Item { width: 30; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: constants.streaming
                    onCheckedChanged: if (root.status === PageStatus.Active) constants.streaming = checked
                    platformStyle: SwitchStyle { inverted: true }
                }
            }

            Text {
                text: qsTr('Update interval:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                opacity: !constants.streaming ? 1.0 : 0.5
            }

            Slider {
                id: updateInterval
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                enabled: !constants.streaming
                valueIndicatorVisible: true
                valueIndicatorText: qsTr('%1 min(s)', 'update interval', value).arg(value)
                valueIndicatorMargin: 20
                value: constants.updateInterval
                onValueChanged: if (root.status === PageStatus.Active) constants.updateInterval = value

                states: [
                    State {
                        name: "disabled"
                        when: updateInterval.value === 0
                        PropertyChanges {
                            target: updateInterval
                            valueIndicatorText: qsTr('OFF')
                        }
                    }
                ]
            }

            Text {
                text: qsTr('Restoring last position:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Row {
                Item { width: 30; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: !constants.restoringLastPositionDisabled
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.restoringLastPositionDisabled = !checked
                    platformStyle: SwitchStyle { inverted: true }
                }
            }

            Text {
                text: qsTr('Screen saver:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Row {
                Item { width: 30; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: !constants.screenSaverDisabled
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.screenSaverDisabled = !checked
                }
            }

            Text {
                text: qsTr('Notifications:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Row {
                spacing: 10
                Item { width: 20; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: constants.mentionsNotification
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.mentionsNotification = checked
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('Mentions')
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    MouseArea { anchors.fill: parent; onClicked: constants.mentionsNotification = !constants.mentionsNotification }
                }
            }

            Row {
                spacing: 10
                Item { width: 20; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: constants.messagesNotification
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.messagesNotification = checked
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('Direct Messages')
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    MouseArea { anchors.fill: parent; onClicked: constants.messagesNotification = !constants.messagesNotification }
                }
            }

            Row {
                spacing: 10
                Item { width: 20; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: constants.searchesNotification
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.searchesNotification = checked
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('Saved Searches')
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    MouseArea { anchors.fill: parent; onClicked: constants.searchesNotification = !constants.searchesNotification }
                }
            }

            Row {
                spacing: 10
                Item { width: 40; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: constants.notificationsWithHapticsFeedback
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.notificationsWithHapticsFeedback = checked
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('with vibration')
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    MouseArea { anchors.fill: parent; onClicked: constants.notificationsWithHapticsFeedback = !constants.notificationsWithHapticsFeedback }
                }
            }

            Text {
                text: qsTr('QNeptunea update check:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                visible: !currentVersion.trusted
            }

            Row {
                visible: !currentVersion.trusted
                Item { width: 30; height: 1 }

                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: !constants.updateCheckDisabled
                    onCheckedChanged: if (root.status == PageStatus.Active) constants.updateCheckDisabled = !checked
                    platformStyle: SwitchStyle { inverted: true }
                }
            }

            Item {
                width: parent.width
                height: constants.fontDefault
            }

            Button {
                anchors.right: parent.right
                iconSource: 'image://theme/icon-m-toolbar-update'.concat(theme.inverted ? "-white" : "")
                text: qsTr('Sign out...')
                platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                onClicked: {
                    signOutConfirmation.open()
                }
            }
        }
    }

    Flickable {
        id: pluginsView
        anchors.top: delegate.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.footerHeight

        contentHeight: pluginsContainer.height
        clip: true

        Column {
            id: pluginsContainer
            width: parent.width
            spacing: 4

            Repeater {
                model: settingsPlugins.pluginInfo
                delegate: AbstractListDelegate {
                    width: parent.width
                    height: constants.fontLarge * 3
                    icon: model.plugin.icon
                    text: model.plugin.name

                    onClicked: {

                        pageStack.push(Qt.createComponent(model.plugin.page))
                    }
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {}

        ToolIcon {
            id: showDetail
            platformIconId: "toolbar-settings"
            opacity: enabled ? 1.0 : 0.5
            onClicked: root.state = 'detail'
        }

        ToolIcon {
            id: showTheme
            platformIconId: "toolbar-frequent-used"
            opacity: enabled ? 1.0 : 0.5
            onClicked: root.state = 'theme'
        }

        ToolIcon {
            id: showPlugins
            platformIconId: "toolbar-tools"
            opacity: enabled ? 1.0 : 0.5
            onClicked: root.state = 'plugins'
        }

    }

    state: 'detail'
    states: [
        State {
            name: 'theme'
            PropertyChanges { target: root; title: qsTr('Settings - Theme'); busy: qneptuneaTheme.loading || userTimeline.loading }
            PropertyChanges { target: detailView; opacity: 0 }
            PropertyChanges { target: pluginsView; opacity: 0 }
            PropertyChanges { target: showTheme; enabled: false }
        },
        State {
            name: 'detail'
            PropertyChanges { target: root; title: qsTr('Settings - Detail'); busy: userTimeline.loading }
            PropertyChanges { target: themeView; opacity: 0 }
            PropertyChanges { target: pluginsView; opacity: 0 }
            PropertyChanges { target: showDetail; enabled: false }
        },
        State {
            name: 'plugins'
            PropertyChanges { target: root; title: qsTr('Settings - Plugins'); busy: userTimeline.loading }
            PropertyChanges { target: detailView; opacity: 0 }
            PropertyChanges { target: themeView; opacity: 0 }
            PropertyChanges { target: showPlugins; enabled: false }
        }
    ]

    transitions: [
        Transition {
            from: "theme"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "detail"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "plugins"
            NumberAnimation { properties: 'opacity' }
        }
    ]
}
