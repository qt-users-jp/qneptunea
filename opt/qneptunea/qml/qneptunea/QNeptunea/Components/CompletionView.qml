import QtQuick 1.1

ListView {
    id: root
    width: 200
    height: 240
    clip: true

    property bool icon: false
    property string filter
    signal clicked(string candidate)

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutExpo }
    }

    delegate: MouseArea {
        id: delegate
        width: root.width
        height: active ? 48 : 0
        property bool active: model.key.substring(0, root.filter.length - 1).toLowerCase() === root.filter.substring(1).toLowerCase()
        clip: true

        Behavior on height {
            NumberAnimation { easing.type: Easing.OutExpo }
        }

        ProfileImage {
            id: avatar
            width: root.icon ? 48 : 0
            height: 48
            source: root.icon ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(model.key) : ''
            visible: delegate.active
        }
        Text {
            anchors.left: avatar.right
            anchors.leftMargin: constants.listViewMargins
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 24
            font.family: constants.fontFamily
            text: (root.icon ? '@' : '#').concat(model.key)
            elide: Text.ElideRight
            visible: delegate.active
        }
        onClicked: root.clicked(model.key)
    }
    Rectangle { anchors.fill: parent; color: 'white'; z: -1 }
}
