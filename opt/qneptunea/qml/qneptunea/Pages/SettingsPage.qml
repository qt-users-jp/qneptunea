import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Delegates'

AbstractPage {
    id: root

    SettingsPageConnectivityTab {
        id: connectivity
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: connectivity }

    SettingsPageAppearanceTab {
        id: appearance
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: appearance }

    SettingsPagePluginsTab {
        id: plugins
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: plugins }

    SettingsPageMiscTab {
        id: misc
        anchors.fill: parent
        anchors.topMargin: root.headerHeight
        anchors.bottomMargin: root.footerHeight
        opacity: 0
        visible: opacity > 0
    }
    ScrollBar { target: misc }

    toolBarLayout: AbstractToolBarLayout {
        ButtonRow {
            TabButton {
                id: showConnectivity
                iconSource: 'image://theme/icon-m-toolbar-refresh'.concat(theme.inverted ? "-white" : "")
                checkable: true
                checked: true
            }

            TabButton {
                id: showAppearance
                iconSource: 'image://theme/icon-m-toolbar-gallery'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }

            TabButton {
                id: showPlugins
                iconSource: 'image://theme/icon-m-toolbar-settings'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }

            TabButton {
                id: showMisc
                iconSource: 'image://theme/icon-m-toolbar-list'.concat(theme.inverted ? "-white" : "")
                checkable: true
            }
        }
    }

    states: [
        State {
            name: 'connectivity'
            when: showConnectivity.checked
            PropertyChanges { target: root; title: qsTr('Connectivity') }
            PropertyChanges { target: connectivity; opacity: 1; status: root.status }
        },
        State {
            name: 'appearance'
            when: showAppearance.checked
            PropertyChanges { target: root; title: qsTr('Appearance'); busy: appearance.loading }
            PropertyChanges { target: appearance; opacity: 1; status: root.status }
        },
        State {
            name: 'plugins'
            when: showPlugins.checked
            PropertyChanges { target: root; title: qsTr('Plugins') }
            PropertyChanges { target: plugins; opacity: 1; status: root.status }
        },
        State {
            name: 'misc'
            when: showMisc.checked
            PropertyChanges { target: root; title: qsTr('Misc') }
            PropertyChanges { target: misc; opacity: 1; status: root.status }
        }
    ]

    transitions: [
        Transition {
            from: 'connectivity'
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: 'appearance'
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "plugins"
            NumberAnimation { properties: 'opacity' }
        },
        Transition {
            from: "misc"
            NumberAnimation { properties: 'opacity' }
        }
    ]
}
