import QtQuick 1.1
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: screen_name ? '@' + screen_name: ''
    busy: friendModel.loading || model.loading

    UserListView {
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        model: UsersModel {
            id: friendModel

            FollowersModel {
                id: model
                user_id: root.id_str
                property variant ids: []
                onSizeChanged: {
                    var ids = []
                    for (var i = 0; i < model.size; i++) {
                        ids.push(model.get(i).id_str ? model.get(i).id_str : model.get(i).id)
                    }
//                    console.debug(ids)
                    model.ids = ids
                }

                Timer {
                    running: model.ids.length > 0 && !friendModel.loading
                    interval: 100
                    repeat: true
                    onTriggered: {
//                        console.debug('triggered')
                        var ids = model.ids
                        var user_id = []
                        for (var i = 0; i < 100 && ids.length > 0; i++) {
                            user_id.push(ids.shift())
                        }
//                        console.debug(user_id)
                        model.ids = ids
                        friendModel.user_id = user_id.join(',')
                        friendModel.reload();
                    }
                }
            }
        }
        onShowDetail: pageStack.push(userPage, {'id_str': detail.id_str})
    }

    toolBarLayout: AbstractToolBarLayout {
        ToolSpacer {columns: 2}
        AddShortcutButton {
            shortcutIcon: 'http://api.twitter.com/1/users/profile_image?screen_name='.concat(screen_name).concat('&size=bigger')
            shortcutUrl: 'followers://'.concat(id_str).concat('/').concat(screen_name)
        }
        ToolSpacer {}
    }
}
