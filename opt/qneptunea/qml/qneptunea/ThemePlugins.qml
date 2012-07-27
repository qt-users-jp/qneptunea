import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'theme'
    property ListModel pluginInfo: ListModel{id: pluginInfo}

    Timer {
        running: true
        interval: 1000
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
//            var pluginInfo = []
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window, {visible: false})
                    pluginInfo.append({'preview': object.preview, 'author': object.author, 'path': root.plugins[i], 'description': object.description, 'vote': -1, 'voted': false, 'download': '', 'source': ''})
                    object.destroy()
                } else {
                    console.debug(root.plugins[i], component.errorString())
                }
            }
        }
    }
}
