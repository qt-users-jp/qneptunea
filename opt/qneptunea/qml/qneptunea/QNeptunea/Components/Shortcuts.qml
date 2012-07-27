import QtQuick 1.1
import QNeptunea 1.0

Item {
    id: root
    width: 480
    height: 80

    property bool editing: false

    GridView {
        id: shortcutView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 80
        interactive: false
        cellWidth: shortcutView.width / 6
        cellHeight: shortcutView.height

        model: shortcutModel
        delegate: shortcutDelegate
    }

    Component {
        id: shortcutDelegate
        Item {
            id: cell
            width: GridView.view.cellWidth; height: GridView.view.cellHeight
            ProfileImage {
                id: item
                source: model.icon
                parent: handler
                x: cell.x + (cell.width - width) / 2; y: cell.y + (cell.height - height) / 2
                width: 73; height: 73
                smooth: true

                Image {
                    id: subIcon
                    property string type: model.link.substring(0, model.link.indexOf(':'))
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 40; height: 40
                    smooth: true
                    states: [
                        State {
                            when: subIcon.type == 'list' || subIcon.type == 'listed' || subIcon.type == 'lists'
                            PropertyChanges {
                                target: subIcon
                                source: 'image://theme/icon-m-toolbar-list-white'
                            }
                        },
                        State {
                            when: subIcon.type == 'following'
                            PropertyChanges {
                                target: subIcon
                                source: 'image://theme/icon-m-toolbar-reply-white'
                            }
                        },
                        State {
                            when: subIcon.type == 'followers'
                            PropertyChanges {
                                target: subIcon
                                source: 'image://theme/icon-m-toolbar-forward-white'
                            }
                        },
                        State {
                            when: subIcon.type == 'user' || subIcon.type == 'searchusers'
                            PropertyChanges {
                                target: subIcon
                                source: 'image://theme/icon-m-toolbar-contact-white'
                            }
                        },
                        State {
                            when: subIcon.type == 'favourites'
                            PropertyChanges {
                                target: subIcon
                                source: 'image://theme/icon-m-toolbar-favorite-mark-white'
                            }
                        }
                    ]
                }

                Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                SequentialAnimation on rotation { id: animation
                    NumberAnimation { to:  10; duration: 100 }
                    NumberAnimation { to: -10; duration: 200 }
                    NumberAnimation { to:  0; duration: 100 }
                    running: false
                    loops: Animation.Infinite; alwaysRunToEnd: true
                }
                states: [
                    State {
                        name: 'active'
                        when: root.editing && handler.currentId == gridId
                        PropertyChanges {
                            target: item
                            x: handler.mouseX - width/2
                            scale: 1.50
                            z: 10
                            transformOrigin: Item.Bottom
                        }
                    },
                    State {
                        name: 'inactive'
                        when: root.editing && handler.currentId > -1
                        PropertyChanges { target: item; scale: 0.90; opacity: 0.75 }
                        PropertyChanges { target: animation; running: true }
                    },
                    State {
                        name: 'editing'
                        when: root.editing
                        PropertyChanges { target: animation; running: true }
                        PropertyChanges { target: remove; visible: true }
                    }
                ]
                transitions: [
                    Transition { from: 'active'; NumberAnimation { properties: "scale, opacity, x, y"; duration: 150; easing.type: Easing.OutCubic} },
                    Transition { from: 'inactive'; NumberAnimation { properties: "scale, opacity, x, y"; duration: 150; easing.type: Easing.OutCubic} }
                ]
            }
            Image {
                id: remove
                parent: handler
                x: cell.x + (cell.width - width) + 10
                y: cell.y - 10
                Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                width: 48
                height: width
                smooth: true
                visible: false
                source: 'image://theme/icon-m-framework-close-thumbnail'
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        shortcutModel.remove(model.index)
                    }
                }
            }
            GridView.onRemove: SequentialAnimation {
                PropertyAction { target: cell; property: "GridView.delayRemove"; value: true }
                PropertyAction { target: remove; property: "visible"; value: false }
                NumberAnimation { target: item; properties: "scale"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                PropertyAction { target: cell; property: "GridView.delayRemove"; value: false }
            }
        }
    }

    MouseArea {
        id: handler
        property int currentId: -1
        property int newIndex
        property int index: shortcutView.indexAt(mouseX, height / 2) // Item underneath cursor
        anchors.fill: shortcutView
        hoverEnabled: true
        onClicked: {
            var item = shortcutModel.get(newIndex = index)
            if (root.editing) {
            } else {
                var arr = item.link.split('/')
                var type = arr.shift()
                arr.shift()
                var id_str = arr.shift()
                var screen_name = arr.shift()
                var params = {'id_str': id_str, 'screen_name': screen_name }
                switch (type) {
                case 'user:':
                    pageStack.push(userPage, params)
                    break
                case 'usertimeline:':
                    pageStack.push(userTimelinePage, params)
                    break
                case 'list:':
                    pageStack.push(listStatusesPage, params)
                    break
                case 'lists:':
                    pageStack.push(listsPage, params)
                    break
                case 'listed:':
                    pageStack.push(listedPage, params)
                    break
                case 'favourites:':
                    pageStack.push(favouritesPage, params)
                    break
                case 'following:':
                    pageStack.push(followingPage, params)
                    break
                case 'followers:':
                    pageStack.push(followersPage, params)
                    break
                case 'search:':
                    pageStack.push(searchPage, params)
                    break
                case 'searchusers:':
                    pageStack.push(searchUsersPage, params)
                    break
                default:
                    console.debug(item.link)
                    break
                }

            }
        }

        onPressed: {
            if (root.editing) {
                console.debug(newIndex, index)
                if (index > -1)
                    currentId = shortcutModel.get(newIndex = index).gridId
            }
        }

        onPressAndHold: {
            if (root.editing) {
                // edit item
            } else {
                console.debug('press and hold')
                currentId = shortcutModel.get(newIndex = index).gridId
                root.editing = true
            }
        }
        onReleased: currentId = -1
        onMousePositionChanged: if (handler.currentId != -1 && index != -1 && index != newIndex) shortcutModel.move(newIndex, newIndex = index, 1)
        z: 1
    }

    Connections {
        target: shortcutModel
        onCountChanged: if (shortcutModel.count == 0) root.editing = false
    }
}
