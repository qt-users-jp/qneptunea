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
import QNeptunea 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    title: qsTr('Theme')
    busy: downloader.running

    property variant source
    property alias preview: preview.source
    property int retweet_count: -1
    property bool retweeted: false
    property string author
    property string description
    property alias localPath: downloader.localPath
    property alias remoteUrl: downloader.remoteUrl
    property alias profile_image_url: profileImage.source

    ThemeDownloader {
        id: downloader
    }

    Flow {
        id: themeView
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        Image {
            id: preview
            width: Math.min(themeView.width, themeView.height)
            height: width
            fillMode: Image.PreserveAspectFit
            smooth: true

            Text {
                anchors.centerIn: parent
                text: 'TBD\nphoto in tweet will\nbe shown here'
                horizontalAlignment: Text.AlignHCenter
                smooth: true
                rotation: -20
                font.pixelSize: 50
                font.bold: true
                style: Text.Outline
                styleColor: 'white'
                visible: preview.status === Image.Null
            }

            ProgressBar {
                id: progress
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                minimumValue: 0
                maximumValue: 100
                value: downloader.progress
                visible: downloader.running
                indeterminate: true

                states: [
                    State {
                        name: "loading"
                        when: progress.value > 0 && progress.value < 100
                        PropertyChanges {
                            target: progress
                            indeterminate: false
                        }
                    }
                ]
            }
        }

        Flickable {
            width: window.inPortrait ? themeView.width : themeView.width - themeView.height
            height: window.inPortrait ? themeView.height - themeView.width : themeView.height
            contentHeight: container.height
            clip: true
            Column {
                id: container
                width: parent.width
                Row {
                    visible: root.source !== '' && root.source.id_str.length > 0
                    ProfileImage {
                        id: profileImage
                        anchors.verticalCenter: parent.verticalCenter
                        width: constants.listViewIconSize
                        height: width
                        smooth: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(statusPage, {'id_str': root.source.id_str})
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: '@'.concat(root.author)
                        color: constants.nameColor
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(statusPage, {'id_str': root.source.id_str})
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: root.description ? root.description : 'TBD\ntweet message will be shown here'
                    color: constants.textColor
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    wrapMode: Text.Wrap
                    MouseArea {
                        anchors.fill: parent
                        enabled: root.source !== '' && root.source.id_str.length > 0
                        onClicked: pageStack.push(statusPage, {'id_str': root.source.id_str})
                    }
                }

                Button {
                    anchors.right: parent.right
                    visible: root.retweet_count > 0
                    enabled: !root.retweeted
                    iconSource: '../images/retweet'.concat(theme.inverted ? "-white.png" : '.png')
                    text: qsTr('%1 times retweeted').arg(root.retweet_count)
                    platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                    onClicked: pageStack.push(tweetPage, {'in_reply_to': root.source})
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolButtonRow {
            ToolButton {
                id: button

                enabled: !downloader.cancelling
                checked: true
                text: qsTr('Apply')

                onClicked: {
                    switch (state) {
                    case '':
                    case 'applied':
                        apply()
                        break
                    case 'downloading':
                        downloader.cancel()
                        break
                    case 'download':
                        downloader.start()
                        break
                    }
                }

                states: [
                    State {
                        name: 'applied'
                        when: constants.themeId == downloader.themeFile
                        PropertyChanges {
                            target: button
                            text: qsTr('Applied')
                            checked: false
                        }
                    },
                    State {
                        name: 'downloading'
                        when: downloader.running && !downloader.exists
                        PropertyChanges {
                            target: button
                            text: qsTr('Cancel')
                            checked: false
                        }
                    },
                    State {
                        name: 'download'
                        when: !downloader.exists
                        PropertyChanges {
                            target: button
                            text: qsTr('Download')
                        }
                    }
                ]
                function apply() {
                    var component = Qt.createComponent(downloader.themeFile)
                    console.debug('component.status', component.status)
                    if (component.status === Component.Ready) {
                        var newTheme = component.createObject(root, {'visible': false})
                        constants.themeId = downloader.themeFile
                        constants.themeInverted = newTheme.inverted
                        constants.splashPortrait = ''.concat(newTheme.splashPortrait).substring(7)
                        constants.splashLandscape = ''.concat(newTheme.splashLandscape).substring(7)
                        constants.backgroundPortrait = newTheme.backgroundPortrait
                        constants.backgroundLandscape = newTheme.backgroundLandscape
                        constants.headerHeightPortrait = newTheme.headerHeightPortrait
                        constants.headerHeightLandscape = newTheme.headerHeightLandscape
                        constants.logoPortrait = newTheme.logoPortrait
                        constants.logoLandscape = newTheme.logoLandscape
                        constants.titleColorPortrait = newTheme.titleColorPortrait
                        constants.titleColorLandscape = newTheme.titleColorLandscape
                        constants.titleFontPixelSizePortrait = newTheme.titleFontPixelSizePortrait
                        constants.titleFontPixelSizeLandscape = newTheme.titleFontPixelSizeLandscape
                        constants.textColorPortrait = newTheme.textColorPortrait
                        constants.textColorLandscape = newTheme.textColorLandscape
                        constants.linkStylePortrait = newTheme.linkStylePortrait.replace(/"/g, '')
                        constants.linkStyleLandscape = newTheme.linkStyleLandscape.replace(/"/g, '')
                        constants.hashTagStylePortrait = newTheme.hashTagStylePortrait.replace(/"/g, '')
                        constants.hashTagStyleLandscape = newTheme.hashTagStyleLandscape.replace(/"/g, '')
                        constants.screenNameStylePortrait = newTheme.screenNameStylePortrait.replace(/"/g, '')
                        constants.screenNameStyleLandscape = newTheme.screenNameStyleLandscape.replace(/"/g, '')
                        constants.sourceStylePortrait = newTheme.sourceStylePortrait.replace(/"/g, '')
                        constants.sourceStyleLandscape = newTheme.sourceStyleLandscape.replace(/"/g, '')
                        constants.mediaStylePortrait = newTheme.mediaStylePortrait.replace(/"/g, '')
                        constants.mediaStyleLandscape = newTheme.mediaStyleLandscape.replace(/"/g, '')
                        constants.placeStylePortrait = newTheme.placeStylePortrait.replace(/"/g, '')
                        constants.placeStyleLandscape = newTheme.placeStyleLandscape.replace(/"/g, '')
                        constants.iconLeftMarginPortrait = newTheme.iconLeftMarginPortrait
                        constants.iconLeftMarginLandscape = newTheme.iconLeftMarginLandscape
                        constants.nameColorPortrait = newTheme.nameColorPortrait
                        constants.nameColorLandscape = newTheme.nameColorLandscape
                        constants.contentColorPortrait = newTheme.contentColorPortrait
                        constants.contentColorLandscape = newTheme.contentColorLandscape
                        constants.separatorNormalColorPortrait = newTheme.separatorNormalColorPortrait
                        constants.separatorNormalColorLandscape = newTheme.separatorNormalColorLandscape
                        constants.separatorFromMeColorPortrait = newTheme.separatorFromMeColorPortrait
                        constants.separatorFromMeColorLandscape = newTheme.separatorFromMeColorLandscape
                        constants.separatorToMeColorPortrait = newTheme.separatorToMeColorPortrait
                        constants.separatorToMeColorLandscape = newTheme.separatorToMeColorLandscape
                        constants.scrollBarColorPortrait = newTheme.scrollBarColorPortrait
                        constants.scrollBarColorLandscape = newTheme.scrollBarColorLandscape
                        constants.notificationIconForMentions = newTheme.notificationIconForMentions
                        constants.notificationIconForMessages = newTheme.notificationIconForMessages
                        constants.notificationIconForSearches = newTheme.notificationIconForSearches
                        newTheme.destroy()
                        pageStack.pop()
                    } else {
                        console.debug('ERROR:', component.errorString())
                    }
                }
            }
        }

        ToolIcon {
            platformIconId: "toolbar-delete"
            enabled: constants.themeId != downloader.themeFile && downloader.remoteUrl.length > 0 && downloader.exists
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                downloader.cleanup()
            }
        }
    }
}
