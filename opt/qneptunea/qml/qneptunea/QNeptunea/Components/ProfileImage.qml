import QtQuick 1.1
import QNeptunea 1.0

Item {
    id: root
    width: image.sourceSize.width
    height: image.sourceSize.height
    property alias source: profileImage.source
    property alias _id: profileImage._id
    property alias smooth: image.smooth

    Image {
        id: image
        anchors.fill: parent
        source: profileImage.cache
//        opacity: status === Image.Ready ? 1.0 : 0.0
//        Behavior on opacity { NumberAnimation {} }
    }

    ProfileImageUrl {
        id: profileImage
    }
}
