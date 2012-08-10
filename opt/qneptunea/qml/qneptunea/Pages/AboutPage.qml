import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractLinkPage {
    id: root

    title: qsTr('QNeptunea for N9 %1').arg(currentVersion.version)
    visualParent: container

    Flickable {
        id: container
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight

        contentHeight: content.height
        clip: true
        interactive: typeof root.linkMenu === 'undefined'

        Column {
            id: content
            width: parent.width
            spacing: 5

            Item { width: 5; height: 5 }

            Text {
                text: qsTr('A <a style="%1;" href="search://#Twitter">#Twitter</a> client for <a style="%1;" href="search://#Nokia">#Nokia</a> <a style="%1;" href="search://#N9">#N9</a>').arg(constants.hashTagStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Rectangle { width: parent.width; height: 2; color: constants.separatorNormalColor }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/projects/qneptunea">QNeptunea website</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }
            Text {
                text: qsTr('Powerd by: <a style="%1;" href="http://dev.qtquick.me/projects/twitter4qml">Twitter4QML</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('includes: <a style="%1;" href="http://quazip.sourceforge.net/">QuaZIP</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/documents/6">Feedback</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Text {
                text: qsTr('<a style="%1;" href="http://dev.qtquick.me/documents/7">Contribution</a>').arg(constants.linkStyle)
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
                onLinkActivated: root.openLink(link)
            }

            Rectangle { width: parent.width; height: 2; color: constants.separatorNormalColor }

            Text {
                text: qsTr('Developer:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: task_jp
                User {
                    id: task_jp
                    screen_name: 'task_jp'
                }
                onClicked: pageStack.push(userPage, {'id_str': task_jp.id_str})
            }
            Text {
                text: qsTr('Graphics:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: logonAniket
                User {
                    id: logonAniket
                    screen_name: 'LogonAniket'
                }
                onClicked: pageStack.push(userPage, {'id_str': logonAniket.id_str})
            }
            Text {
                text: qsTr('Contributor:')
                font.family: constants.fontFamily
                font.pixelSize: constants.fontXLarge
                color: constants.textColor
            }
            UserDelegate {
                width: parent.width
                user: kenya888
                User {
                    id: kenya888
                    screen_name: 'kenya888'
                }
                onClicked: pageStack.push(userPage, {'id_str': kenya888.id_str})
            }
        }
    }

    ScrollDecorator { flickableItem: container }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 3}
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            enabled: typeof root.linkMenu !== 'undefined'
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                root.linkMenu.close()
            }
        }
    }
}
