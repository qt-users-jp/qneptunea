import QNeptunea.Tweet 1.0
import QNeptunea 1.0
import QtQuick 1.1

TweetPlugin {
    id: root
    name: qsTr('Upload media to Mobypicture')
    icon: './mobypicture/mobypicture.png'

    enabled: root.media.length > 0

    property variant uploader: PhotoUploader {
        id: uploader
        verifyCredentialsFormat: 'json'

        onDone: {
            var json = JSON.parse(result)
            if (ok && typeof json.media.mediaurl !== 'undefined') {
                if (root.text.length > 0 && root.text.substring(root.text.substring(root.text.length - 1, 1) !== ' '))
                    root.text += ' '
                root.text += json.media.mediaurl
                var media = []
                root.media = media
                root.message = qsTr('Uploaded!')
            } else {
                root.message = result
            }

            root.loading = false
        }
    }

    function exec() {
        if (root.media.length !== 1) return;

        root.loading = true

        var parameters = {
            'key': 'c2Jrcx5OMfMzEZy1'
            , 'media': root.media[0]
        }
        uploader.upload('https://api.mobypicture.com/2.0/upload.json', parameters)
    }
}

