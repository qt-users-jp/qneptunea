import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
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
                    text: qsTr('<a style="%1" href="http://www.instapaper.com/">http://www.instapaper.com/</a>').arg(constants.linkStyle)
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
