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
import com.nokia.extras 1.0
import Twitter4QML 1.0
import QNeptunea.Components 1.0

AbstractLinkPage {
    id: root

    title: qsTr('Microsoft Translator')
    visualParent: container

    property url __icon: 'mstranslator.png'
    property bool signedIn: clientId.length > 0 && clientSecret.length > 0

    property string clientId: settings.readData('microsofttranslator.com/client_id', 'qneptunea')
    property string clientSecret: settings.readData('microsofttranslator.com/client_secret', 'PEpfJi37mU8wBvvutyntOiX0VslIHuehGiFLgAbKLlw=')

    property bool dirty: false

    ListModel {
        id: langSource
        ListElement { code: 'ar'; value: QT_TR_NOOP("Arabic") }
        ListElement { code: 'bg'; value: QT_TR_NOOP("Bulgarian") }
        ListElement { code: 'ca'; value: QT_TR_NOOP("Catalan") }
        ListElement { code: 'zh-CHS'; value: QT_TR_NOOP("Chinese (Simplified)") }
        ListElement { code: 'zh-CHT'; value: QT_TR_NOOP("Chinese (Traditional)") }
        ListElement { code: 'cs'; value: QT_TR_NOOP("Czech") }
        ListElement { code: 'da'; value: QT_TR_NOOP("Danish") }
        ListElement { code: 'nl'; value: QT_TR_NOOP("Dutch") }
        ListElement { code: 'en'; value: QT_TR_NOOP("English") }
        ListElement { code: 'et'; value: QT_TR_NOOP("Estonian") }
        ListElement { code: 'fa'; value: QT_TR_NOOP("Fersian (Farsi)") }
        ListElement { code: 'fi'; value: QT_TR_NOOP("Finnish") }
        ListElement { code: 'fr'; value: QT_TR_NOOP("French") }
        ListElement { code: 'de'; value: QT_TR_NOOP("German") }
        ListElement { code: 'el'; value: QT_TR_NOOP("Greek") }
        ListElement { code: 'ht'; value: QT_TR_NOOP("Haitian Creole") }
        ListElement { code: 'he'; value: QT_TR_NOOP("Hebrew") }
        ListElement { code: 'hi'; value: QT_TR_NOOP("Hindi") }
        ListElement { code: 'hu'; value: QT_TR_NOOP("Hungarian") }
        ListElement { code: 'id'; value: QT_TR_NOOP("Indonesian") }
        ListElement { code: 'it'; value: QT_TR_NOOP("Italian") }
        ListElement { code: 'ja'; value: QT_TR_NOOP("Japanese") }
        ListElement { code: 'ko'; value: QT_TR_NOOP("Korean") }
        ListElement { code: 'lv'; value: QT_TR_NOOP("Latvian") }
        ListElement { code: 'lt'; value: QT_TR_NOOP("Lithuanian") }
        ListElement { code: 'mww'; value: QT_TR_NOOP("Hmong Daw") }
        ListElement { code: 'no'; value: QT_TR_NOOP("Norwegian") }
        ListElement { code: 'pl'; value: QT_TR_NOOP("Polish") }
        ListElement { code: 'pt'; value: QT_TR_NOOP("Portuguese") }
        ListElement { code: 'ro'; value: QT_TR_NOOP("Romanian") }
        ListElement { code: 'ru'; value: QT_TR_NOOP("Russian") }
        ListElement { code: 'sk'; value: QT_TR_NOOP("Slovak") }
        ListElement { code: 'sl'; value: QT_TR_NOOP("Slovenian") }
        ListElement { code: 'es'; value: QT_TR_NOOP("Spanish") }
        ListElement { code: 'sv'; value: QT_TR_NOOP("Swedish") }
        ListElement { code: 'th'; value: QT_TR_NOOP("Thai") }
        ListElement { code: 'tr'; value: QT_TR_NOOP("Turkish") }
        ListElement { code: 'uk'; value: QT_TR_NOOP("Ukrainian") }
        ListElement { code: 'vi'; value: QT_TR_NOOP("Vietnamese") }
    }

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
                    source: './mstranslator.png'
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('<a style="%1" href="%2">Subscribe & Register</a>').arg(constants.linkStyle).arg('http://msdn.microsoft.com/en-us/library/hh454950.aspx')
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
                text: qsTr('client_id:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: clientId
                width: parent.width
                enabled: !root.busy && !root.signedIn
                text: root.clientId.length > 0 ? root.clientId : 'qneptunea'
                maximumLength: 50
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Next'
                }
                Keys.onReturnPressed: clientSecret.forceActiveFocus()
                onTextChanged: if (focus) dirty = true
            }

            Text {
                text: qsTr('client_secret:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: clientSecret
                width: parent.width
                enabled: !root.busy && !root.signedIn
                text: root.clientSecret.length > 0 ? root.clientSecret : 'PEpfJi37mU8wBvvutyntOiX0VslIHuehGiFLgAbKLlw='
                maximumLength: 100
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Sign In'
                }
                Keys.onReturnPressed: button.signIn()
                onTextChanged: if (focus) dirty = true
            }

            Text {
                text: qsTr('translate to:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                height: 256
                Tumbler {
                    columns: [
                        TumblerColumn {
                            id: to
                            items: ListModel {
                                id: langModel
                                Component.onCompleted: {
                                    for (var i = 0; i < langSource.count; i++) {
                                        var l = langSource.get(i)
                                        l.value = qsTr(l.value)
                                        langModel.append(l)
                                    }
                                }
                            }
                        }
                    ]
                    onChanged: {
                        settings.saveData('microsofttranslator.com/to', langModel.get(to.selectedIndex).code)
                    }
                    Component.onCompleted: {
                        var message = qsTr('en (Please translate this "en" to closest langage code in http://msdn.microsoft.com/en-us/library/hh456380.)')
                        var lang = settings.readData('microsofttranslator.com/to', message.substring(0, message.indexOf(' (')))
                        for (var i = 0; i < langModel.count; i++) {
                            var l = langSource.get(i)
                            if (langModel.get(i).code === lang) {
                                to.selectedIndex = i
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolButtonRow {
            ToolButton {
                id: button

                enabled: !root.busy && (root.signedIn || (clientId.text.length > 0 && clientSecret.text.length > 0)) && root.dirty
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

                    var url = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
                    var query = 'grant_type=client_credentials&client_id='.concat(encodeURIComponent(clientId.text)).concat('&client_secret=').concat(encodeURIComponent(clientSecret.text)).concat('&scope=').concat(encodeURIComponent('http://api.microsofttranslator.com'))

                    var responseText = ''
                    var request = new XMLHttpRequest()
                    request.open('POST', url)
                    request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                    request.onreadystatechange = function() {
                                request.onreadystatechange = function() {
            //                                console.debug(request.readyState)
                                            switch (request.readyState) {
                                            case XMLHttpRequest.HEADERS_RECEIVED:
                                                break
                                            case XMLHttpRequest.LOADING:
                                                responseText = request.responseText
                                                break
                                            case XMLHttpRequest.DONE: {
                                                if (request.responseText.length > 0)
                                                    responseText = request.responseText
                                                var json
                                                try {
                                                    json = JSON.parse(responseText)
                                                } catch(e) {
                                                    root.message(responseText, root.__icon)
                                                    root.busy = false
                                                    break
                                                }

                                                if (typeof json.access_token !== 'undefined') {
                                                    settings.saveData('microsofttranslator.com/client_id', clientId.text)
                                                    settings.saveData('microsofttranslator.com/client_secret', clientSecret.text)
                                                    pageStack.pop()
                                                } else if (typeof json.error !== 'undefined') {
                                                    root.message(qsTr('Failed: %1').arg(json.error), root.__icon)
                                                } else {
                                                    root.message(qsTr('Failed'), root.__icon)
                                                }
                                                root.busy = false
                                                break }
                                            case XMLHttpRequest.ERROR: {
                                                root.message(qsTr('Failed'), root.__icon)
                                                root.busy = false
                                                break }
                                            }
                                        }
                            }
                    request.send(query)
                }

                function signOut() {
                    root.busy = true
                    clientId.text = ''
                    clientSecret.text = ''
                    settings.saveData('microsofttranslator.com/client_id', '')
                    settings.saveData('microsofttranslator.com/client_secret', '')
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
