import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'tweet'
    property ListModel pluginInfo: ListModel{id: pluginInfo}

    Timer {
        running: true
        interval: 1000
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window)
                    pluginInfo.append({'name': object.name, 'icon': object.icon, 'plugin': object})
                } else {
                    var errString = component.errorString()
                    console.debug(root.plugins[i], errString)
                }
            }
        }
    }
}
