import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import QNeptunea.Components 1.0

AbstractLinkPage {
    id: root

    title: qsTr('Pocket')
    visualParent: container

    property url __icon: 'getpocket.png'
    property string api: 'https://readitlaterlist.com/v2/auth'
    property string apikey: 'c95TIV28g7177l4f1bda1b9v7dp3q62b'
    property bool signedIn: settings.readData('getpocket.com/username', '').length > 0 && settings.readData('getpocket.com/password', '').length > 0

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
                    source: './getpocket.png'
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('<a style="%1" href="http://getpocket.com/">http://getpocket.com/</a>').arg(constants.linkStyle)
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
                text: qsTr('username:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: username
                width: parent.width
                enabled: !root.busy
                text: settings.readData('getpocket.com/username', '')
                maximumLength: 20
                platformStyle: TextFieldStyle { textFont.pixelSize: constants.fontDefault }
                platformSipAttributes: SipAttributes {
                    actionKeyLabel: 'Next'
                }
                Keys.onReturnPressed: password.forceActiveFocus()
            }

            Text {
                text: qsTr('password:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                color: constants.textColor
            }

            TextField {
                id: password
                width: parent.width
                enabled: !root.busy
                text: settings.readData('getpocket.com/password', '')
                maximumLength: 100
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

                    var url = api.concat('?apikey=').concat(apikey).concat('&username=').concat(username.text).concat('&password=').concat(password.text)

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
                                                if (request.responseText == '200 OK') {
                                                    settings.saveData('getpocket.com/username', username.text)
                                                    settings.saveData('getpocket.com/password', password.text)
                                                    pageStack.pop()
                                                } else {
                                                    root.message(request.responseText, root.__icon)
                                                }
                                                root.busy = false
                                                break }
                                            case XMLHttpRequest.ERROR: {
                                                root.message(request.responseText, root.__icon)
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
                    settings.saveData('getpocket.com/username', '')
                    settings.saveData('getpocket.com/password', '')
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
