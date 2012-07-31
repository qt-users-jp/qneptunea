import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

Item {
    id: root
    width: 400
    height: container.height

    property variant user
    property bool followsYou: false

    signal avatarClicked(variant user)
    signal userClicked(variant user)
    signal linkActivated(string link)

    property StateGroup __pluginItem
    property string translated: __pluginItem ? __pluginItem.result : ''

    function translate() {
        var plugin = translationPlugins.pluginMap['Microsoft Translator V2']
//        console.debug(plugin)
        if (typeof plugin !== 'undefined') {
            var component = Qt.createComponent(plugin)
            if (component.status === Component.Ready) {
                var lang = LANG
                if (lang.indexOf('_') > -1)
                    lang = lang.substring(0, lang.indexOf('_'))
                root.__pluginItem = component.createObject(root)
                root.__pluginItem.translate('<html><body>'.concat(root.user.description).concat('</body></html>'), root.user.description, lang)
            } else {
                console.debug(component.errorString())
            }
        } else {
            console.debug('plugin not found')
        }
    }

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: constants.listViewScrollbarWidth
        height: detailArea.y + detailArea.height + 10 + 2

        Item {
            id: userArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(iconArea.height, nameArea.height) + constants.listViewScrollbarWidth * 2
            Item {
                id: iconArea
                anchors.left: parent.left
                anchors.leftMargin: constants.iconLeftMargin
                anchors.top: parent.top
                anchors.topMargin: 5
                width: 73
                height: width

                ProfileImage {
                    anchors.fill: parent
                    source: user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(user.screen_name).concat('&size=bigger') : ''
                    _id: user.profile_image_url ? user.profile_image_url : ''

                    Image {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: -10
                        opacity: user.protected ? 0.75 : 0.0
                        source: 'image://theme/icon-m-common-locked'.concat(theme.inverted ? "-inverse" : "")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.avatarClicked(root.user)
                    }
                }
            }

            Column {
                id: nameArea
                anchors.left: iconArea.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: constants.listViewMargins

                Text {
                    text: user.name ? user.name : ''
                    textFormat: Text.PlainText
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Row {
                    spacing: constants.fontDefault
                    Text {
                        text: user.screen_name ? '@' + user.screen_name : ''
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.nameColor
                    }
                    Text {
                        text: qsTr('FOLLOWS YOU')
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontDefault
                        color: constants.textColor
                        visible: root.followsYou
                    }
                }
            }
        }

        Column {
            id: detailArea
            anchors.top: userArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: constants.listViewMargins

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: user.description.replace(/\r/g, '')
                textFormat: Text.PlainText
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontDefault * 1.40
                opacity: translated.length > 0 ? 0.75 : 1.0
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: translated
                visible: translated.length > 0
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontLarge * 1.40
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                onLinkActivated: root.linkActivated(link)
            }

            Text {
                width: parent.width
                text: qsTr('<a style="%2" href="%1">%1</a>').arg(user.location).arg(constants.placeStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSmall
                color: constants.textColor
            }
            Text {
                width: parent.width
                text: qsTr('<a style="%2" href="%1">%1</a>').arg(user.url).arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontDefault

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (user.url.length > 0) root.linkActivated(user.url)
                }
            }
        }
    }
}
