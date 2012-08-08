import QNeptunea.Service 1.0

ServicePlugin {
    id: root
    service: qsTr('Share')
    icon: 'image://theme/icon-m-toolbar-share'.concat(theme.inverted ? "-white" : "")

    function open(link, parameters, feedback) {
        root.loading = true
        share.url = link
        share.mimeType = 'text/x-url'
        if (typeof parameters.openLink !== 'undefined') {
            share.title = link
        } else {
            share.title = parameters.user.name
            share.description = parameters.text
        }
        share.share()
        root.loading = false
    }
}
