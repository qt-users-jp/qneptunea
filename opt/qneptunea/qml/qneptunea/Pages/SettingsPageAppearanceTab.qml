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
import com.nokia.extras 1.0
import Twitter4QML 1.1
import '../QNeptunea/Components/'
import '../Delegates'

Page {
    id: root
    property bool loading: userTimeline.loading || qneptuneaTheme.loading

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: container.height
        clip: true

        UserTimelineModel {
            id: qneptuneaTheme
            screen_name: 'QNeptuneaTheme'
            count: 100
            sortKey: 'retweet_count'
            property int lastSize: 0
            onLoadingChanged: {
                if (loading) return
                if (size !== 0) {
                    // read all data
                    for (var i = 0; i < size; i++) {
                        themes.add(get(i))
                    }
                } else {
                    reload()
                }
            }

            onRateLimitExceeded: {
                infoBanners.rateLimitMessage(xrlLimit, xrlRemaining, xrlReset)
            }
        }

        Timer {
            running: themePlugins.pluginInfo.count > 0
            interval: 500
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
                if (data.retweeted_status.entities.media.length !== 1) return
                if (data.retweeted_status.entities.urls.length !== 1) return

                var theme = data.retweeted_status
                var found = false
                for (var i = 0; i < count; i++) {
                    if (get(i).vote < 0) continue
                    if (get(i).vote < theme.retweet_count) {
                        insert(i, {'preview': theme.entities.media[0].media_url_https, 'author': theme.user.screen_name, 'path': '.local/share/data/QNeptunea/QNeptunea/theme/'.concat(theme.id_str), 'description': theme.rich_text.replace(/<a .*?>.*?<\/a>/g, ''), 'vote': theme.retweet_count, 'voted': theme.retweeted, 'download': theme.entities.urls[0].expanded_url, 'source': theme, 'profile_image_url': theme.user.profile_image_url })
                        found = true
                        break
                    }
                }
                if (!found) {
                    append({'preview': theme.entities.media[0].media_url_https, 'author': theme.user.screen_name, 'path': '.local/share/data/QNeptunea/QNeptunea/theme/'.concat(theme.id_str), 'description': theme.rich_text.replace(/<a .*?>.*?<\/a>/g, ''), 'vote': theme.retweet_count, 'voted': theme.retweeted, 'download': theme.entities.urls[0].expanded_url, 'source': theme, 'profile_image_url': theme.user.profile_image_url })
                }
            }
        }

        TumblerColumn {
            id: firstColumn
            items: ListModel { id: firstColumnModel }
        }

        TumblerColumn {
            id: secondColumn
            items: ListModel { id: secondColumnModel }
        }

        TumblerColumn {
            id: thirdColumn
            items: ListModel { id: thirdColumnModel }
        }

        Component.onCompleted: {
            var dateFormat = constants.dateFormat

            var dateFormats = ['d', 'M', 'MMM']
            var separators = [' ', '-', '/', '.']

            for (var i = 0; i < dateFormats.length; i++) {
                var f = dateFormats[i]
                firstColumnModel.append({'format': f, 'value': Qt.formatDateTime(new Date(), f)})
                if (dateFormat.substring(0, f.length) === f) {
                    firstColumn.selectedIndex = i
                }
            }

            dateFormat = dateFormat.substring(dateFormats[firstColumn.selectedIndex].length)
            console.debug(dateFormat)

            for (var i = 0; i < separators.length; i++) {
                var s = separators[i]
                secondColumnModel.append({'format': s, 'value': s})
                if (dateFormat.substring(0, s.length) === s) {
                    secondColumn.selectedIndex = i
                }
            }

            dateFormat = dateFormat.substring(separators[secondColumn.selectedIndex].length)
            console.debug(dateFormat)

            for (var i = 0; i < dateFormats.length; i++) {
                var f = dateFormats[i]
                thirdColumnModel.append({'format': f, 'value': Qt.formatDateTime(new Date(), f)})
                if (dateFormat.substring(0, f.length) === f) {
                    thirdColumn.selectedIndex = i
                }
            }
        }

        UserTimelineModel {
            id: userTimeline
            count: 1

            onRateLimitExceeded: {
                infoBanners.rateLimitMessage(xrlLimit, xrlRemaining, xrlReset)
            }
        }

        Column {
            id: container
            width: parent.width
            spacing: 4

            StatusDelegate {
                width: parent.width

                item: userTimeline.size > 0 ? userTimeline.get(0) : undefined
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
                text: qsTr('List spacing:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Slider {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                minimumValue: 0
                maximumValue: 20
                value: constants.listViewSpacing
                onValueChanged: if (root.status === PageStatus.Active) constants.listViewSpacing = value
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
                text: qsTr('Date format:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: constants.fontDefault * 15
                height: 256
                Tumbler {
                    id: dateFormat
                    columns: [ firstColumn, secondColumn, thirdColumn ]
                    onChanged: {
                        var dateFormat = firstColumnModel.get(firstColumn.selectedIndex).format
                        dateFormat += secondColumnModel.get(secondColumn.selectedIndex).format
                        dateFormat += thirdColumnModel.get(thirdColumn.selectedIndex).format
                        console.debug(dateFormat)
                        constants.dateFormat = dateFormat
                    }
                }
            }

            Text {
                text: qsTr('Color scheme:')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
            }

            Flow {
                width: parent.width
                Repeater {
                    model: ListModel {
                        ListElement { name: 'basement'; prefix: 'meegotouch-button/' }
                        ListElement { name: 'color2'; prefix: 'color2-' }
                        ListElement { name: 'color3'; prefix: 'color3-' }
                        ListElement { name: 'color4'; prefix: 'color4-' }
                        ListElement { name: 'color5'; prefix: 'color5-' }
                        ListElement { name: 'color6'; prefix: 'color6-' }
                        ListElement { name: 'color7'; prefix: 'color7-' }
                        ListElement { name: 'color8'; prefix: 'color8-' }
                        ListElement { name: 'color9'; prefix: 'color9-' }
                        ListElement { name: 'color10'; prefix: 'color10-' }
                        ListElement { name: 'color11'; prefix: 'color11-' }
                        ListElement { name: 'color12'; prefix: 'color12-' }
                        ListElement { name: 'color13'; prefix: 'color13-' }
                        ListElement { name: 'color14'; prefix: 'color14-' }
                        ListElement { name: 'color15'; prefix: 'color15-' }
                        ListElement { name: 'color16'; prefix: 'color16-' }
                        ListElement { name: 'color17'; prefix: 'color17-' }
                        ListElement { name: 'color18'; prefix: 'color18-' }
                        ListElement { name: 'color19'; prefix: 'color19-' }
                    }

                    delegate: MouseArea {
                        width: 60
                        height: 60
                        Image {
                            id: icon
                            anchors.centerIn: parent
                            source: '/usr/share/themes/blanco/meegotouch/images/theme/'.concat(model.name).concat('/').concat(model.prefix).concat('meegotouch-button-accent').concat(theme.inverted ? '-inverted-background.png' : '-background.png')
                            scale: constants.themeColorScheme === model.index + 1 ? 1.25 : 1.0
                            smooth: true
                            Behavior on scale { NumberAnimation { easing.type: Easing.OutBack } }
                        }

                        onClicked: {
                            console.debug(icon.source)
                            constants.themeColorScheme = model.index + 1
                        }
                    }
                }
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
                            source: typeof model.profile_image_url !== 'undefined' ? model.profile_image_url : ''
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
                                parameters.profile_image_url = model.profile_image_url
                                if (typeof model.vote === 'undefined') {
                                } else {
                                    parameters.remoteUrl = model.download
                                    console.debug(parameters.remoteUrl)
                                }
                                pageStack.push(themePage, parameters)
                            }
                        }
                    }
                }
            }
        }
    }

    ScrollBar { target: flickable }
}
