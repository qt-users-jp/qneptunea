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
