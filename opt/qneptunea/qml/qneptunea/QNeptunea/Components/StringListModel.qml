import QtQuick 1.1
import Twitter4QML 1.0

ListModel {
    id: root
    property string key

    function add(value) {
        for (var i = 0; i < root.count; i++) {
            if (value == root.get(i).key) {
                root.move(i, 0, 1)
                return
            }
        }
        root.insert(0, {'key': value})
    }

    property Timer time: Timer {
        running: true
        repeat: false
        interval: 500
        onTriggered: readData()
    }

    function readData() {
        var values = settings.readData(root.key, '').split(',')
        for (var i = 0; i < values.length; i++) {
            if (values[i].length > 0)
                root.append( {'key': values[i]} )
        }
    }

    Component.onDestruction: {
        if (oauth.state === OAuth.Authorized) {
            var values = []
            for (var i = 0; i < root.count && i < 100; i++) {
                if (root.get(i).key.length > 0)
                    values.push(root.get(i).key)
            }
            console.debug(values)
            settings.saveData(root.key, values.join(','))
        }
    }

    property Connections connections: Connections {
        target: oauth
        onStateChanged: {
            if (oauth.state === OAuth.Unauthorized) {
                console.debug('oauth.state', oauth.state)
                settings.saveData(root.key, '')
            }
        }
    }
}
