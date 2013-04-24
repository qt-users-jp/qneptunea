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

Item {
    id: api
    width: 854
    height: 854
    property bool inPortrait: true

    /* public APIs */

    // theme
    property bool inverted: true

    // splash image
    property url splashPortrait
    property url splashLandscape

    // notification icon (should be 64x64 ?)
    // these icons should be located at /usr/share/themes/blanco/meegotouch/icons/
    // current way (retweet by QNeptuneaTheme) doesn't support this icons
    // you need to create a theme package(.deb)
    // sample package tbd
    property string notificationIconForMentions: 'icon-m-service-qneptunea-mention'
    property string notificationIconForMessages: 'icon-m-service-qneptunea-message'
    property string notificationIconForSearches: 'icon-m-service-qneptunea'

    // background images
    property url backgroundPortrait
    property url backgroundLandscape

    // header
    property int headerHeightPortrait: 72
    property int headerHeightLandscape: 46
    property url logoPortrait: 'logo-portrait.png'
    property url logoLandscape: 'logo-landscape.png'
    property color titleColor: 'white'
    property color titleColorPortrait: titleColor
    property color titleColorLandscape: titleColor
    property int titleFontPixelSize: 30
    property int titleFontPixelSizePortrait: titleFontPixelSize
    property int titleFontPixelSizeLandscape: titleFontPixelSize

    // ui in general
    property color textColor: inverted ? '#FFFFFF' : '#191919'
    property color textColorPortrait: textColor
    property color textColorLandscape: textColor

    property string linkStyle
    property string linkStylePortrait: linkStyle
    property string linkStyleLandscape: linkStyle

    property string hashTagStyle
    property string hashTagStylePortrait: hashTagStyle
    property string hashTagStyleLandscape: hashTagStyle

    property string screenNameStyle
    property string screenNameStylePortrait: screenNameStyle
    property string screenNameStyleLandscape: screenNameStyle

    property string sourceStyle
    property string sourceStylePortrait: sourceStyle
    property string sourceStyleLandscape: sourceStyle

    property string mediaStyle
    property string mediaStylePortrait: mediaStyle
    property string mediaStyleLandscape: mediaStyle

    property string placeStyle
    property string placeStylePortrait: placeStyle
    property string placeStyleLandscape: placeStyle

    // list
    property int iconLeftMargin: 0
    property int iconLeftMarginPortrait: iconLeftMargin
    property int iconLeftMarginLandscape: iconLeftMargin

    property color nameColor: inverted ? '#FFFFFF' : '#191919'
    property color nameColorPortrait: nameColor
    property color nameColorLandscape: nameColor

    property color contentColor: inverted ? '#FFFFFF' : '#191919'
    property color contentColorPortrait: contentColor
    property color contentColorLandscape: contentColor

    property color separatorNormalColor: inverted ? '#FFFFFF' : '#191919'
    property color separatorNormalColorPortrait: separatorNormalColor
    property color separatorNormalColorLandscape: separatorNormalColor

    property color separatorFromMeColor: '#0000FF'
    property color separatorFromMeColorPortrait: separatorFromMeColor
    property color separatorFromMeColorLandscape: separatorFromMeColor

    property color separatorToMeColor: '#FF0000'
    property color separatorToMeColorPortrait: separatorToMeColor
    property color separatorToMeColorLandscape: separatorToMeColor

    property color scrollBarColor: '#00FF00'
    property color scrollBarColorPortrait: scrollBarColor
    property color scrollBarColorLandscape: scrollBarColor

    /* private APIs for debugging */
    property string title: 'Preview'
    property string author: 'task_jp'

    Item {
        anchors.fill: parent
        Rectangle {
            id: root
            width: api.inPortrait ? 480 : 854
            height: api.inPortrait ? 854 : 480
            color: 'black'

            Item {
                id: statusBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: api.inPortrait ? 36 : 0
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: '0:00'
                    color: 'white'
                    font.pixelSize: 20
                    visible: api.inPortrait
                }
            }

            Image {
                id: splash
                anchors.centerIn: parent
                source: api.inPortrait ? api.splashPortrait : api.splashLandscape
                z: 1
                rotation: api.inPortrait ? 90 : 0

                SequentialAnimation {
                    id: splashAnimation
                    running: true
                    NumberAnimation {
                        target: splash
                        properties: 'opacity'
                        from: 0
                        to: 1
                        duration: 0
                    }
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: splash
                        properties: 'opacity'
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
                Connections {
                    target: api
                    onInPortraitChanged: splashAnimation.running = true
                }
            }

            Image {
                id: background
                anchors.top: statusBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                source: api.inPortrait ? api.backgroundPortrait : api.backgroundLandscape
            }

            Item {
                id: header
                anchors.top: statusBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: api.inPortrait ? api.headerHeightPortrait : api.headerHeightLandscape

                Image {
                    id: logo
                    anchors.verticalCenter: parent.verticalCenter
                    x: y
                    source: api.inPortrait ? api.logoPortrait : api.logoLandscape
                }

                Text {
                    id: title
                    anchors.centerIn: parent
                    font.pixelSize: api.inPortrait ? api.titleFontPixelSizePortrait : api.titleFontPixelSizeLandscape
                    font.bold: true
                    color: api.inPortrait ? api.titleColorPortrait : api.titleColorLandscape
                    text: api.title
                }

                MouseArea { anchors.fill: parent; onClicked: api.inPortrait = !api.inPortrait }
            }

            ListView {
                id: view
                anchors.top: header.bottom
                anchors.bottom: footer.top
                anchors.right: parent.right
                anchors.left: parent.left
                clip: true
                model: qneptuneaModel
                delegate: qneptuneaDelegate

                Rectangle {
                    id: scrollBar
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 5
                    radius: 2
                    height: view.height * view.indexAt(0, view.contentY + 5) / view.count
                    color: api.inPortrait ? api.scrollBarColorPortrait : api.scrollBarColorLandscape
                    opacity: 0.75
                }
            }

            Image {
                id: footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                source: (api.inPortrait ? 'footer-portrait' : 'footer-landscape').concat(api.inverted ? '-inverted.png' : '.png')
                MouseArea { anchors.fill: parent; onClicked: api.inPortrait = !api.inPortrait }
            }

            XmlListModel {
                id: qneptuneaModel

                source: 'http://search.twitter.com/search.atom?q=QNeptunea%20-RT'

                namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; " +
                                       "declare namespace twitter=\"http://api.twitter.com/\";";

                query: "/feed/entry"

                XmlRole { name: "text"; query: "content/string()" }
                XmlRole { name: "name"; query: "author/name/string()" }
                XmlRole { name: "screen_name"; query: "author/name/string()" }
                XmlRole { name: "profile_image_url"; query: "link[@rel = 'image']/@href/string()" }

            }

            Component {
                id: qneptuneaDelegate
                Item {
                    width: parent.width
                    height: Math.max(icon.height, rightPane.height) + 12

                    Image {
                        id: icon
                        source: model.profile_image_url
                        y: 5
                        x: api.inPortrait ? api.iconLeftMarginPortrait : api.iconLeftMarginLandscape
                        width: 48
                        height: 48
                        smooth: true
                    }

                    Column {
                        id: rightPane
                        anchors.left: icon.right
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        y: 5

                        Row {
                            id: nameArea
                            spacing: 5
                            property int indexOf: model.name.indexOf('(')
                            Text {
                                id: name
                                text: model.name.substring(nameArea.indexOf + 1, model.name.length - 1)
                                font.bold: true
                                font.pixelSize: 20
                                color: api.inPortrait ? api.nameColorPortrait : api.nameColorLandscape
                            }
                            Text {
                                id: screenName
                                text: '@'.concat(model.screen_name.substring(0, nameArea.indexOf - 1))
                                font.pixelSize: 20
                                color: api.inPortrait ? api.nameColorPortrait : api.nameColorLandscape
                            }
                        }

                        Text {
                            id: content
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: model.text.replace(/<.*?>/g, '')
                            font.pixelSize: 24
                            color: api.inPortrait ? api.contentColorPortrait : api.contentColorLandscape
                        }
                    }

                    Rectangle {
                        id: separator
                        width: parent.width - 5
                        height: 2
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        color: api.inPortrait ? api.separatorNormalColorPortrait : api.separatorNormalColorLandscape

                        states: [
                            State {
                                name: 'fromMe'
                                when: screenName.text == '@'.concat(api.author)
                                PropertyChanges { target: separator; color: api.inPortrait ? api.separatorFromMeColorPortrait : api.separatorFromMeColorLandscape }
                            },
                            State {
                                name: 'toMe'
                                when: content.text.indexOf('@'.concat(api.author)) > -1
                                PropertyChanges { target: separator; color: api.inPortrait ? api.separatorToMeColorPortrait : api.separatorToMeColorLandscape }
                            }
                        ]
                    }
                }
            }
        }
    }
}
