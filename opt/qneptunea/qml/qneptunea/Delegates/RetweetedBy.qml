import QtQuick 1.1
import com.nokia.meego 1.0
import '../QNeptunea/Components/'

Row {
    id: root
    anchors.right: parent.right
    spacing: constants.listViewMargins
    property variant user

    Image {
        source: '../images/retweet'.concat(theme.inverted ? '-white.png' : '.png')
        anchors.verticalCenter: parent.verticalCenter
        smooth: true
        width: constants.listViewIconSize / 2
        height: width
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: user.name ? user.name : ''
        textFormat: Text.PlainText
        color: constants.nameColor
        font.pixelSize: constants.fontSmall
        font.family: constants.fontFamily
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: constants.listViewIconSize / 2
        height: width + constants.listViewMargins
        ProfileImage {
            anchors.centerIn: parent
            width: constants.listViewIconSize / 2
            height: width
            source: user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=').concat(constants.listViewIconSizeName) : ''
            _id: user.profile_image_url ? user.profile_image_url : ''
            smooth: true
        }
    }
}
