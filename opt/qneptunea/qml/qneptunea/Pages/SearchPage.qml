import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../Views'
import '../Delegates'
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: unescape(root.id_str)
    busy: model.loading || savedSearchesModel.loading

    property string id_str

    property int __topIndex: view.indexAt(0, view.contentY)
    property variant __topData: model.get(__topIndex)

    StateGroup {
        states: [
            State {
                name: "show time"
                when: view.moving && __topData.created_at
                PropertyChanges {
                    target: root
                    title: Qt.formatDateTime(new Date(__topData.created_at), 'M/d hh:mm')
                }
            }
        ]
        transitions: [
            Transition { NumberAnimation {} }
        ]
    }

    SearchListView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        highlightRangeMode: ListView.NoHighlightRange
        header: Item {}
        model: SearchModel {
            id: model
            q: unescape(root.id_str)
            result_type: 'recent'
            rpp: 100
            sortKey: 'id_str'
        }
        onReload: {
            model.since_id = model.size == 0 ? '' : model.get(0).id_str
            model.until = ''
            model.reload()
        }
        onMore: {
            model.since_id = ''
            model.until = model.size == 0 ? '' : model.get(model.size - 1).id_str
            model.reload()
        }
        onShowDetail: pageStack.push(statusPage, {'id_str': detail.id_str})
        onLinkActivated: root.openLink(link)
    }

    Menu {
        id: menu
        visualParent: view
        property int savedIndex: savedSearchesModel.searchTerms.indexOf(unescape(root.id_str).toLowerCase())
        MenuLayout {
            MenuItemWithIcon {
                property bool muted: window.filters.indexOf(root.id_str) > -1
                iconSource: 'image://theme/icon-m-toolbar-volume'.concat(muted ? '' : '-off').concat(theme.inverted ? "-white" : "")
                text: muted ? qsTr('Unmute %1').arg(root.id_str) : qsTr('Mute %1').arg(root.id_str)
                onClicked: {
                    var filters = window.filters
                    if (muted) {
                        var index = filters.indexOf(root.id_str)
                        while (index > -1) {
                            filters.splice(index, 1)
                            index = filters.indexOf(root.id_str)
                        }
                    } else {
                        filters.unshift(root.id_str)
                    }
                    window.filters = filters
                }
            }
            MenuItemWithIcon {
                property bool saved: menu.savedIndex < 0
                iconSource: 'image://theme/icon-m-toolbar-favorite'.concat(saved ? '-unmark' : '-mark').concat(theme.inverted ? "-white" : "")
                text: saved ? qsTr('Save search') : qsTr('Remove saved search')
                onClicked: {
                    if (saved)
                        savedSearchesModel.createSavedSearch({'query': unescape(root.id_str)})
                    else
                        savedSearchesModel.destroySavedSearch({'id': savedSearchesModel.get(menu.savedIndex).id})
                }
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'image://theme/icon-l-search'
            shortcutUrl: 'search://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            opacity: enabled ? 1.0 : 0.5
            onClicked: {
                if (menu.status == DialogStatus.Closed)
                    menu.open()
                else
                    menu.close()
            }
        }
        onClosing: menu.close()
    }
}
