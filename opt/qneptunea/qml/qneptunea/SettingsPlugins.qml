import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'settings'
    property ListModel pluginInfo: ListModel{id: pluginInfo}

    Timer {
        running: true
        interval: 2500
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window)
                    pluginInfo.append({'plugin': object})
                } else {
                    console.debug(root.plugins[i], component.errorString())
                }
            }
        }
    }
}
