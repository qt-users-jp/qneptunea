import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

Page {
    id: root

    signal back

    TitleBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        text: qsTr('Authentication')
    }

    Column {
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 20
        Button {
            id: start
            text: qsTr('1. Start')
            enabled: false
            onClicked: oauth.request_token()
        }
        TextField {
            id: pin
            width: start.width
            placeholderText: qsTr('2. Enter 7 digits pin code')
            enabled: false
            inputMask: '0000000'
            inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
            platformSipAttributes: SipAttributes {
                actionKeyLabel: qsTr('OK')
                actionKeyEnabled: authorize.enabled
            }
            Keys.onReturnPressed: oauth.access_token(pin.text)
        }

        Button {
            id: authorize
            text: qsTr('3. Authorize')
            enabled: false
            onClicked: oauth.access_token(pin.text)
        }

        Button {
            id: cancel
            text: qsTr('Cancel')
            enabled: true
            onClicked: {
                pin.text = ''
                oauth.unauthorize()
            }
        }
    }

    Timer {
        running: state == 'RequestTokenReceived'
        interval: 10
        repeat: false
        onTriggered: oauth.authorize()
    }

    states: [
        State {
            name: "Unauthorized"
            when: oauth.state === OAuth.Unauthorized
            PropertyChanges {
                target: start
                enabled: true
            }
            PropertyChanges {
                target: cancel
                enabled: true
            }
        },
        State {
            name: "ObtainUnauthorizedRequestToken"
            when: oauth.state === OAuth.ObtainUnauthorizedRequestToken
            PropertyChanges {
                target: header
                busy: true
            }
        },
        State {
            name: "RequestTokenReceived"
            when: oauth.state === OAuth.RequestTokenReceived
            PropertyChanges {
                target: header
                busy: true
            }
        },
        State {
            name: "InputVerifier"
            when: oauth.state === OAuth.UserAuthorizesRequestToken && pin.text.length != 7
            PropertyChanges {
                target: pin
                enabled: true
            }
            PropertyChanges {
                target: cancel
                enabled: true
            }
            StateChangeScript {
                script: pin.forceActiveFocus()
            }
        },
        State {
            name: "UserAuthorizesRequestToken"
            when: oauth.state === OAuth.UserAuthorizesRequestToken && pin.text.length == 7
            PropertyChanges {
                target: pin
                enabled: true
            }
            PropertyChanges {
                target: authorize
                enabled: true
            }
            PropertyChanges {
                target: cancel
                enabled: true
            }
        },
        State {
            name: "ExchangeRequestTokenForAccessToken"
            when: oauth.state === OAuth.ExchangeRequestTokenForAccessToken
            PropertyChanges {
                target: header
                busy: true
            }
        },
        State {
            name: "Authorized"
            when: oauth.state === OAuth.Authorized
            StateChangeScript {
                script: {
//                    console.debug(pageStack.depth)
                    pageStack.pop()
//                    console.debug(pageStack.depth)
                }
            }
        }
    ]
}
