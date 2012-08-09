import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

Flickable {
    id: root

    property int status: PageStatus.Inactive
    property bool loading: userTimeline.loading || qneptuneaTheme.loading
    contentHeight: container.height
    clip: true

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

    Column {
        id: container
        width: parent.width
        spacing: 4

//        busy: userTimeline.loading

        StatusDelegate {
            width: parent.width

            UserTimelineModel { id: userTimeline; count: 1 }

            item: userTimeline.size > 0 ? userTimeline.get(0) : undefined
            user: userTimeline.size > 0 ? userTimeline.get(0).user : undefined
        }

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
            text: qsTr('Theme:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        Flow {
            width: parent.width

            Repeater {
                model: themes

                delegate: Image {
                    width: 160
                    height: 160
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
        }
    }
}