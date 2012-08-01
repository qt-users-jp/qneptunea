import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'

MouseArea {
    id: root
    width: 400
    height: container.height

    property bool temporary: false
    property variant item
    property variant user

    property bool retweeted: item.retweeted_status !== undefined && item.retweeted_status.user !== undefined
    property variant __item: retweeted ? item.retweeted_status : item
    property bool __favorited: __item.favorited

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
                root.__pluginItem.translate('<html><body>'.concat(root.__item.rich_text).concat('</body></html>'), root.__item.plain_text, lang)
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
        height: detailArea.y + detailArea.height + 12
        clip: true

        Rectangle {
            id: line
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: constants.separatorHeight
            color: constants.separatorNormalColor
            opacity: constants.separatorOpacity

            states: [
                State {
                    name: "my tweet"
                    when: root.user.id_str === oauth.user_id
                    PropertyChanges {
                        target: line
                        color: constants.separatorFromMeColor
                    }
                },
                State {
                    name: "mention"
                    when: __item.text.indexOf('@' + oauth.screen_name) > -1
                    PropertyChanges {
                        target: line
                        color: constants.separatorToMeColor
                    }
                }
            ]
        }

        MouseArea {
            id: userArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(iconArea.height, nameArea.height) + 12
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
                    source: root.temporary ? '' : (__item.user.profile_image_url ? 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(__item.user.screen_name).concat('&size=bigger') : '')
                    _id: root.temporary ? '' : (__item.user.profile_image_url ? __item.user.profile_image_url : '')
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
                    text: __item.user && __item.user.name ? __item.user.name : ''
                    textFormat: Text.PlainText
                    font.bold: true
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontLarge
                    color: constants.nameColor
                }
                Text {
                    text: __item.user && __item.user.screen_name ? '@' + __item.user.screen_name : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontDefault
                    color: constants.nameColor
                }
            }

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-common-drilldown-arrow'.concat(theme.inverted ? "-inverse" : "")
            }

            onClicked: root.userClicked(__item.user)
        }

        Column {
            id: detailArea
            anchors.top: userArea.bottom
//            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: constants.listViewMargins

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: '<style type="text/css">a.link{'.concat(constants.linkStyle).concat('} a.screen_name{').concat(constants.screenNameStyle).concat('} a.hash_tag{').concat(constants.hashTagStyle).concat('} a.media{').concat(constants.mediaStyle).concat('}</style>').concat(__item.rich_text)
                lineHeightMode: Text.FixedHeight
                lineHeight: constants.fontLarge * 1.40
                font.family: constants.fontFamily
                font.pixelSize: constants.fontLarge
                color: constants.contentColor
                onLinkActivated: root.linkActivated(link)
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

            Row {
                anchors.left: parent.left
                spacing: constants.listViewMargins

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: __item.created_at ? Qt.formatDateTime(new Date(__item.created_at), 'M/d hh:mm') : ''
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    property variant contributors: __item.contributors && __item.contributors.length > 0 ? __item.contributors[0] : undefined
                    text: qsTr('by <a style="%2" href="user://%1">%1</a>').arg(contributors).arg(constants.screenNameStyle)
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                    visible: contributors !== undefined
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('<style type="text/css">a{%2}</style>via %1').arg(__item.source).arg(constants.sourceStyle)
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSmall
                    color: constants.textColor
                    onLinkActivated: root.linkActivated(link)
                }
            }

        }
    }
    Component.onCompleted: addRetweeted()
    onRetweetedChanged: addRetweeted()
    function addRetweeted() {
        if (root.retweeted && typeof root.user !== 'undefined') {
            var component = Qt.createComponent("RetweetedBy.qml");
            if (component.status == Component.Ready) {
                component.createObject(detailArea, {'user': root.user});
            }
        }
    }
}
