import QtQuick 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

Flickable {
    id: root

    property int status: PageStatus.Inactive
    contentHeight: container.height
    clip: true

    QueryDialog {
        id: signOutConfirmation
        icon: 'image://theme/icon-m-content-third-party-update'.concat(theme.inverted ? "-inverse" : "")
        titleText: qsTr('Sign out')
        message: qsTr('QNeptunea will be closed.')

        acceptButtonText: qsTr('Sign out')
        rejectButtonText: qsTr('Cancel')

        onAccepted: {
            oauth.unauthorize()
            Qt.quit()
        }
    }

    Column {
        id: container
        width: parent.width
        spacing: 4

        Text {
            text: qsTr('Display time-out:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        Row {
            Item { width: 30; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: !constants.screenSaverDisabled
                onCheckedChanged: if (root.status === PageStatus.Active) constants.screenSaverDisabled = !checked
                platformStyle: SwitchStyle { inverted: true }
            }
        }

        Separator { width: parent.width }

        Text {
            text: qsTr('QNeptunea update check:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            visible: !currentVersion.trusted
        }

        Row {
            visible: !currentVersion.trusted
            Item { width: 30; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: !constants.updateCheckDisabled
                onCheckedChanged: if (root.status === PageStatus.Active) constants.updateCheckDisabled = !checked
                platformStyle: SwitchStyle { inverted: true }
            }
        }

        Separator { width: parent.width }

        Text {
            text: qsTr('Language:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            visible: !currentVersion.trusted
        }


        ButtonColumn {
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: app.translations
                delegate: Button {
                    text: model.modelData.name
                    platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                    checked: model.modelData.code === app.translation.code
                    onClicked: {
                        app.translation = model.modelData
                        infoBanners.message({'iconSource': '', 'text': qsTr('Restart QNeptunea')})
                    }
                }
            }
        }

        Separator { width: parent.width }

        Button {
            anchors.right: parent.right
            iconSource: 'image://theme/icon-m-toolbar-update'.concat(theme.inverted ? "-white" : "")
            text: qsTr('Sign out...')
            platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
            onClicked: {
                signOutConfirmation.open()
            }
        }
    }
}
