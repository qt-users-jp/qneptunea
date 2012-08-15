import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: root
    width: 200
    height: 200
    visible: false
    property string url
    property string type: root.__pluginItem && root.__pluginItem.type ? root.__pluginItem.type : ''
    property StateGroup __pluginItem

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: image
        SpinnerImage {
            anchors.fill: parent
            source: root.__pluginItem.thumbnail
            fillMode: Image.PreserveAspectCrop
            clip: true
            smooth: true
            cache: false
        }
    }

    states: [
        State {
            name: "image"
            when: root.type === 'image' || root.type === 'video'
            PropertyChanges { target: loader; sourceComponent: image }
            PropertyChanges { target: root; visible: true }
        },
        State {
            name: "url"
            when: root.type == 'url' && root.__pluginItem.url.length > 0
            PropertyChanges { target: urlUpdate; running: true }
        }
    ]
    Timer {
        id: urlUpdate
        interval: 10
        repeat: false
        running: false
        onTriggered: {
            root.url = root.__pluginItem.url
//            root.__pluginItem.destroy(10)
        }
    }

//    Text {
//        anchors.fill: parent
//        text: root.url
//        styleColor: "#ffffff"
//        wrapMode: Text.WrapAnywhere
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        style: Text.Outline
//        font.pixelSize: constants.fontDefault
//    }

    onClicked: {
        if (root.type == 'web')
            root.parent.openLink(root.__pluginItem.detail)
        else if (root.type == 'image')
            pageStack.push(imagePreviewPage, {'type': root.__pluginItem.type, 'url': root.__pluginItem.detail})
        else if (root.type == 'video')
            pageStack.push(videoPreviewPage, {'type': root.__pluginItem.type, 'url': root.__pluginItem.detail})
    }

    function update() {
        console.debug('update', root.url)
        var a = root.url.split('/')
        a.shift() // http:
        a.shift() //
        var domain = a.shift()
        var parameters = a.join('/')
        console.debug(url, domain, parameters)
        var plugin = previewPlugins.pluginMap[domain]
//        console.debug(plugin)
        if (typeof plugin !== 'undefined') {
            var component = Qt.createComponent(plugin)
            if (component.status === Component.Ready) {
                root.__pluginItem = component.createObject(root)
                if (!root.__pluginItem.load(root.url, domain)) {
                    root.destroy()
                }
            } else {
                console.debug(component.errorString())
                root.destroy()
            }
        } else {
//            root.url = 'http://img.simpleapi.net/small/' + root.url
            root.destroy()
        }
    }

    onUrlChanged: {
        console.debug('onUrlChanged')
        update()
    }
//    Component.onCompleted: {
//        console.debug('onCompleted')
//        update()
//    }
}
