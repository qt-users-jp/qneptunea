import QtQuick 1.1
import QNeptunea 1.0

PluginLoader {
    id: root
    type: 'service'
    property ListModel pluginInfo: ListModel{id: pluginInfo}

    Timer {
        running: true
        interval: 1500
        repeat: false
        onTriggered: readPlugins()
        function readPlugins() {
            for (var i = 0; i < root.plugins.length; i++) {
                var component = Qt.createComponent(root.plugins[i])
                if (component.status === Component.Ready) {
                    var object = component.createObject(window)
                    pluginInfo.append({'name': object.service, 'icon': object.icon, 'plugin': object})
//                    object.destroy()
                } else {
                    console.debug(root.plugins[i], component.errorString())
                }
            }
        }
    }
}
