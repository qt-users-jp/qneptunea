import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'translation'
    property variant pluginMap

    Timer {
        running: true
        interval: 10000
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
            var pluginMap = {}
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window)
                    pluginMap[object.service] = root.plugins[i]
                    object.destroy()
                } else {
                    console.debug(root.plugins[i], component.errorString())
                }
            }
            root.pluginMap = pluginMap
        }
    }
}
