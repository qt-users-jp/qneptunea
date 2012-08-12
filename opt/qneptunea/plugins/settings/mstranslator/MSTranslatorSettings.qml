import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import QNeptunea.Components 1.0

AbstractLinkPage {
    id: root

    title: qsTr('Microsoft Translator')
    visualParent: container

    property url __icon: 'mstranslator.png'
    property bool signedIn: settings.readData('microsofttranslator.com/client_id', '').length > 0 && settings.readData('microsofttranslator.com/client_secret', '').length > 0

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
                enabled: !root.busy
                text: settings.readData('microsofttranslator.com/client_id', '')
                maximumLength: 50
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Next'
                }
                Keys.onReturnPressed: clientSecret.forceActiveFocus()
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
                enabled: !root.busy
                text: settings.readData('microsofttranslator.com/client_secret', '')
                maximumLength: 100
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

                enabled: !root.busy && (root.signedIn || (clientId.text.length > 0 && clientSecret.text.length > 0))
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

//                    var clientId = settings.readData('microsofttranslator.com/clientId', '')
//                    var clientSecret = settings.readData('microsofttranslator.com/clientSecret', '')

                    var url = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
                    var query = 'grant_type=client_credentials&client_id='.concat(clientId.text).concat('&client_secret=').concat(escape(clientSecret.text)).concat('&scope=').concat(escape('http://api.microsofttranslator.com'))

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
                                                break
                                            case XMLHttpRequest.DONE: {
                                                if (typeof JSON.parse(request.responseText).access_token !== 'undefined') {
                                                    settings.saveData('microsofttranslator.com/client_id', clientId.text)
                                                    settings.saveData('microsofttranslator.com/client_secret', clientSecret.text)
                                                    pageStack.pop()
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
                    clientId.text = ''
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
