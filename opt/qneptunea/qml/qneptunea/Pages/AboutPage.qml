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

    title: qsTr('QNeptunea for N9 %1').arg(currentVersion.version)
    visualParent: container

    property string defaultTranslatorTwitterIds: 'translator1_twitter_id,translator2_twitter_id,...'
    property string translatorTwitterIds: qsTr('translator1_twitter_id,translator2_twitter_id,...')
    property string defaultTranslatorTwitterIds2: 'translator_twitter_id(s) (Please translate this "translator_twitter_id(s)" to *your* twitter id(s) like "task_jp" or "task_jp, LogonAniket".)'
    property string translatorTwitterIds2: qsTr('translator_twitter_id(s) (Please translate this "translator_twitter_id(s)" to *your* twitter id(s) like "task_jp" or "task_jp, LogonAniket".)')
    property variant translators: defaultTranslatorTwitterIds === translatorTwitterIds ? [] : translatorTwitterIds.split(/, */)

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        contentHeight: content.height
        clip: true
        interactive: typeof root.linkMenu === 'undefined'

        Column {
            id: content
            width: parent.width
            spacing: 5

            Item { width: 5; height: 5 }

            Text {
                text: qsTr('A <a style="%1;" href="search://#Twitter">#Twitter</a> client for <a style="%1;" href="search://#Nokia">#Nokia</a> <a style="%1;" href="search://#N9">#N9</a>').arg(constants.hashTagStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Rectangle { width: parent.width; height: 2; color: constants.separatorNormalColor }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/projects/qneptunea">QNeptunea website</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }
            Text {
                text: qsTr('Powerd by: <a style="%1;" href="http://dev.qtquick.me/projects/twitter4qml">Twitter4QML</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('includes: <a style="%1;" href="http://quazip.sourceforge.net/">QuaZIP</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/documents/6">Feedback</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/documents/7">Contribution</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Rectangle { width: parent.width; height: 2; color: constants.separatorNormalColor }

            Text {
                text: qsTr('Developer:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: task_jp
                User {
                    id: task_jp
                    screen_name: 'task_jp'
                }
                onClicked: pageStack.push(userPage, {'id_str': task_jp.id_str})
            }
            Text {
                text: qsTr('Graphics:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: logonAniket
                User {
                    id: logonAniket
                    screen_name: 'LogonAniket'
                }
                onClicked: pageStack.push(userPage, {'id_str': logonAniket.id_str})
            }
            Text {
                text: qsTr('Contributor:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: kenya888
                User {
                    id: kenya888
                    screen_name: 'kenya888'
                }
                onClicked: pageStack.push(userPage, {'id_str': kenya888.id_str})
            }
            Text {
                text: qsTr('Translator:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                visible: translators.length > 0
            }
            Repeater {
                model: translators
                UserDelegate {
                    width: content.width
                    user: translator
                    User {
                        id: translator
                        screen_name: model.modelData
                    }
                    onClicked: pageStack.push(userPage, {'id_str': translator.id_str})
                }
            }
        }
    }

    ScrollDecorator { flickableItem: container }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 3}
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            enabled: typeof root.linkMenu !== 'undefined'
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                root.linkMenu.close()
            }
        }
    }
}
