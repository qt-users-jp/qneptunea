import QtQuick 1.1
import '../QNeptunea/Components'

Flickable {
    id: pluginsView

    contentHeight: container.height
    clip: true

    Column {
        id: container
        width: parent.width
        spacing: 4

        Repeater {
            model: settingsPlugins.pluginInfo
            delegate: AbstractListDelegate {
                width: parent.width
                icon: model.plugin.icon
                text: model.plugin.name

                onClicked: pageStack.push(Qt.createComponent(model.plugin.page))
            }
        }
    }
}
