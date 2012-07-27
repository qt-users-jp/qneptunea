import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: root

    property string id_str
    property string screen_name

    property alias title: header.text
    property bool busy: false

    property int headerHeight: header.y + header.height
    property int footerHeight: footer.height * footerOpacity
    property alias toolBarLayout: footer.tools
    property alias footerOpacity: footer.opacity

    function openLink(link, parameters) {
        console.debug(link)
        switch (true) {
        case /^search:\/\//.test(link):
            pageStack.push(searchPage, {'id_str': link.substring(9)})
            break
        case /^user:\/\//.test(link):
            pageStack.push(userPage, {'id_str': link.substring(7)})
            break
        case /^status:\/\//.test(link):
            pageStack.push(statusPage, {'id_str': link.substring(8)})
            break
        }
    }

    function message(text, icon) {
        infoBanners.message({'iconSource': icon, 'text': text})
    }

    signal headerClicked()

    property bool running: false
    property bool currentPluginLoading: false
    Connections {
        target: platformWindow
        onActiveChanged: {
            if (!root.running) return;
            root.running = platformWindow.active
        }
    }

    TitleBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        busy: root.busy || root.running || root.currentPluginLoading
        onClicked: root.headerClicked()
    }

    ToolBar {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 100
        states: [
            State {
                name: 'hidden'
                when: opacity == 0
                PropertyChanges {
                    target: footer
                    visible: false
                    height: 0
                }
            }
        ]
        transitions: [
            Transition {
                NumberAnimation { properties: 'height' }
            }
        ]
    }
}
