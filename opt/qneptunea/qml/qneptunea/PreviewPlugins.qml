import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'preview'
    property variant pluginMap

    Timer {
        running: true
        interval: 2000
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
            var pluginMap = {}
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window)
                    for (var j = 0; j < object.domains.length; j++) {
                        pluginMap[object.domains[j]] = root.plugins[i]
                    }
                    object.destroy()
                } else {
                    console.debug(component.errorString())
                }
            }
            root.pluginMap = pluginMap
        }
    }
}
