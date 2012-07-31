import QNeptunea.Service 1.0

ServicePlugin {
    id: root
    service: qsTr('Copy to clipboard')
    icon: 'image://theme/icon-m-toolbar-tag'.concat(theme.inverted ? "-white" : "")

    function open(link, parameters) {
        root.loading = true
        clipboard.text = typeof parameters.openLink === 'undefined' ? parameters.text : link
        clipboard.selectAll()
        clipboard.cut()
        root.loading = false
    }
}
