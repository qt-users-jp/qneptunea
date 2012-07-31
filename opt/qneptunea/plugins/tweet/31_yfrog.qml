import QNeptunea.Tweet 1.0
import QNeptunea 1.0
import QtQuick 1.1

TweetPlugin {
    id: root
    name: qsTr('Upload media to yfrog')
    icon: './yfrog/yfrog.png'

    enabled: root.media.length > 0

    property variant uploader: PhotoUploader {
        id: uploader
        verifyCredentialsFormat: 'xml'

        onDone: {
            if (ok) {
                xmlParser.xml = result
            } else {
                root.message = result
                root.loading = false
            }
        }
    }

    property variant xmlParser: XmlListModel {
        id: xmlParser
        query: '/rsp'
        XmlRole { name: 'url'; query: 'mediaurl/string()' }
        onCountChanged: {
            if (count == 1) {
                if (root.text.length > 0 && root.text.substring(root.text.substring(root.text.length - 1, 1) !== ' '))
                    root.text += ' '
                root.text += get(0).url
                var media = []
                root.media = media
                root.message = qsTr('Uploaded!')
            } else {
                root.message = xmlParser.xml
            }

            root.loading = false
        }
    }


    function exec() {
        if (root.media.length !== 1) return;

        root.loading = true

        var parameters = {
            'key': '1BCGNSTWa49e1a3b3aeab7cb10a1dcf2ffb6158f'
            , 'media': root.media[0]
        }
        uploader.upload('http://yfrog.com/api/xauth_upload', parameters)
    }
}

