import QtQuick 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

Flickable {
    id: root

    property int status: PageStatus.Inactive
    contentHeight: container.height
    clip: true

    Column {
        id: container
        width: parent.width
        spacing: 4

        Text {
            text: qsTr('Update mode:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        ButtonRow {
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: qsTr('Streaming')
                platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                checked: constants.streaming
                onClicked: {
                    constants.streaming = true
                }
            }
            Button {
                text: qsTr('Timer')
                platformStyle: ButtonStyle { fontPixelSize: constants.fontDefault }
                checked: !constants.streaming
                onClicked: {
                    constants.streaming = false
                }
            }
        }

        Slider {
            id: updateInterval
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 30
            minimumValue: 0
            maximumValue: 10
            stepSize: 1
            enabled: !constants.streaming
            valueIndicatorVisible: true
            valueIndicatorText: qsTr('%1 min(s)', 'update interval', value).arg(value)
            valueIndicatorMargin: 20
            value: constants.updateInterval
            onValueChanged: if (root.status === PageStatus.Active) constants.updateInterval = value

            states: [
                State {
                    name: "disabled"
                    when: updateInterval.value === 0
                    PropertyChanges {
                        target: updateInterval
                        valueIndicatorText: qsTr('OFF')
                    }
                }
            ]
        }

        Separator { width: parent.width }

        Text {
            text: qsTr('Notifications:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        Row {
            spacing: 10
            Item { width: 20; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: constants.mentionsNotification
                onCheckedChanged: if (root.status === PageStatus.Active) constants.mentionsNotification = checked
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr('Mentions')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                MouseArea { anchors.fill: parent; onClicked: constants.mentionsNotification = !constants.mentionsNotification }
            }
        }

        Row {
            spacing: 10
            Item { width: 20; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: constants.messagesNotification
                onCheckedChanged: if (root.status === PageStatus.Active) constants.messagesNotification = checked
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr('Direct Messages')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                MouseArea { anchors.fill: parent; onClicked: constants.messagesNotification = !constants.messagesNotification }
            }
        }

        Row {
            spacing: 10
            Item { width: 20; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: constants.searchesNotification
                onCheckedChanged: if (root.status === PageStatus.Active) constants.searchesNotification = checked
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr('Saved Searches')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                MouseArea { anchors.fill: parent; onClicked: constants.searchesNotification = !constants.searchesNotification }
            }
        }

        Row {
            spacing: 10
            Item { width: 40; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: constants.notificationsWithHapticsFeedback
                onCheckedChanged: if (root.status === PageStatus.Active) constants.notificationsWithHapticsFeedback = checked
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr('with vibration')
                color: constants.textColor
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault
                MouseArea { anchors.fill: parent; onClicked: constants.notificationsWithHapticsFeedback = !constants.notificationsWithHapticsFeedback }
            }
        }

        Separator { width: parent.width }

        Text {
            text: qsTr('Sync:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        Row {
            Item { width: 30; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: constants.sync
                onCheckedChanged: if (root.status === PageStatus.Active) constants.sync = checked
            }
        }

        Separator { width: parent.width }

        Text {
            text: qsTr('Restoring last position:')
            color: constants.textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
        }

        Row {
            Item { width: 30; height: 1 }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: !constants.restoringLastPositionDisabled
                onCheckedChanged: if (root.status === PageStatus.Active) constants.restoringLastPositionDisabled = !checked
                platformStyle: SwitchStyle { inverted: true }
            }
        }
    }
}
