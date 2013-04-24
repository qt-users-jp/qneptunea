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
import QNeptunea.Components 1.0

AbstractLinkPage {
    id: root

    title: qsTr('Instapaper')
    visualParent: container

    property url __icon: 'instapaper.png'
    property string api: 'https://www.instapaper.com/api/authenticate'
    property bool signedIn: settings.readData('instapaper.com/username', '').length > 0 && settings.readData('instapaper.com/password', '').length > 0

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentHeight: content.height
        clip: true
        interactive: typeof root.linkMenu === 'undefined'

        Column {
            id: content
            width: parent.width

            Row {
                spacing: 10
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: './instapaper.png'
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: '<a style="'.concat(constants.linkStyle).concat('" href="http://www.instapaper.com/">http://www.instapaper.com/</a>')
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    font.bold: true
                    onLinkActivated: root.openLink(link)
                }
            }

            Item {
                width: parent.width
                height: 20
            }

            Text {
                text: qsTr('Email address:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: username
                width: parent.width
                enabled: !root.busy
                text: settings.readData('instapaper.com/username', '')
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Next'
                }
                Keys.onReturnPressed: password.forceActiveFocus()
            }

            Text {
                text: qsTr('Password:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: password
                width: parent.width
                enabled: !root.busy
                text: settings.readData('instapaper.com/password', '')
                echoMode: TextInput.Password
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Sign In'
                }
                Keys.onReturnPressed: button.signIn()
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolButtonRow {
            ToolButton {
                id: button

                enabled: !root.busy && (root.signedIn || (username.text.length > 0 && password.text.length > 0))
                checked: enabled
                text: qsTr('Sign In')

                states: [
                    State {
                        name: 'signedIn'
                        when: root.signedIn
                        PropertyChanges {
                            target: button
                            text: qsTr('Sign Out')
                        }
                    }
                ]

                function signIn() {
                    root.busy = true

                    var url = api.concat('?username=').concat(username.text).concat('&password=').concat(password.text)

                    console.debug(url)
                    var request = new XMLHttpRequest();
                    request.open('GET', url);
                    request.onreadystatechange = function() {
                                request.onreadystatechange = function() {
                                            switch (request.readyState) {
                                            case XMLHttpRequest.HEADERS_RECEIVED:
                                                break
                                            case XMLHttpRequest.LOADING:
                                                break
                                            case XMLHttpRequest.DONE: {
                                                if (request.responseText == '200') {
                                                    settings.saveData('instapaper.com/username', username.text)
                                                    settings.saveData('instapaper.com/password', password.text)
                                                    pageStack.pop()
                                                } else {
                                                    root.message('Log in failed', root.__icon)
                                                }
                                                root.busy = false
                                                break }
                                            case XMLHttpRequest.ERROR: {
                                                root.message('Log in failed', root.__icon)
                                                root.busy = false
                                                break }
                                            }
                                        }
                            }
                    request.send();
                }

                function signOut() {
                    root.busy = true
                    username.text = ''
                    password.text = ''
                    settings.saveData('instapaper.com/username', '')
                    settings.saveData('instapaper.com/password', '')
                    root.signedIn = false
                    root.busy = false
                }

                onClicked: {
                    if (button.state == 'signedIn')
                        button.signOut()
                    else
                        button.signIn()
                }
            }
        }
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
