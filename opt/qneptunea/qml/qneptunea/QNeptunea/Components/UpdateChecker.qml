import QtQuick 1.1
import com.nokia.meego 1.0

QueryDialog {
    id: root

    property string applicationName: 'QNeptunea'
    icon: 'file://usr/share/icons/hicolor/256x256/apps/qneptunea256.png'
    titleText: qsTr('New version available')
    message: qsTr('%1 version %2 is available.\nDo you want to download the package?\ncode.google.com/p/qneptunea\n\nIf installation fails, clear brower cache\n$ rm /home/user/.grob/cache/http*/*\nThen download the package again.').arg(root.applicationName).arg(root.version)

    platformStyle: QueryDialogStyle { messageFontPixelSize: 22 }
    property string version
    property url download

    acceptButtonText: qsTr('Download')
    rejectButtonText: qsTr('No thanks')

    onAccepted: ActionHandler.openUrlExternally(root.download)

    Timer {
        running: !currentVersion.trusted
        repeat: false
        interval: 5000
        onTriggered: check()
    }

    function check() {
        if (constants.updateCheckDisabled) return
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            switch (request.readyState) {
            case XMLHttpRequest.HEADERS_RECEIVED:
                break;
            case XMLHttpRequest.LOADING:
                break;
            case XMLHttpRequest.DONE: {
                var text = request.responseText
                if (text.match(/<a href="(\/attachments\/download\/[0-9]+\/qneptunea_([0-9]+\.[0-9]+\.[0-9]+)_armel\.deb)"/)) {
                    root.download = 'http://dev.qtquick.me'.concat(RegExp.$1)
                    root.version = RegExp.$2
                    if (currentVersion.version < root.version) {
                        root.open()
                    }
                } else {
                    console.debug(text)
                }
            }
                break
            case XMLHttpRequest.ERROR:
                break;
            }
        }

        request.open('GET', 'http://dev.qtquick.me/projects/'.concat(applicationName.toLowerCase()).concat('/files'));
        request.send();
    }
}
