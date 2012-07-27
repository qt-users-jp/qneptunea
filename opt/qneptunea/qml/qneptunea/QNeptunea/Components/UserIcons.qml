import QtQuick 1.1
import com.nokia.extras 1.0

Flow {
    id: root
    property alias icon: mark.source
    property variant model: []
    Item {
        width: parent.width
        height: constants.listViewMargins
    }

    Item {
        width: 48
        height: 48
        Image {
            id: mark
        }
        CountBubble {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            value: root.model.length
            largeSized: true
            opacity: 0.75
            visible: value < 100
        }
    }

    Repeater {
        model: root.model
        delegate: ProfileImage {
            width: 48
            height: 48
            source: 'http://api.twitter.com/1/users/profile_image?user_id='.concat(model.modelData)
            MouseArea { anchors.fill: parent; onClicked: pageStack.push(userPage, {'id_str': model.modelData}) }
        }
    }
}
