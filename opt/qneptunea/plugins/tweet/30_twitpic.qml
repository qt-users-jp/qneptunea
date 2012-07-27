import QNeptunea.Tweet 1.0
import QNeptunea 1.0

TweetPlugin {
    id: root
    name: 'Upload media to twitpic'
    icon: './twitpic/twitpic.png'

    enabled: root.media.length > 0

    property variant uploader: PhotoUploader {
        id: uploader
        verifyCredentialsFormat: 'json'

        onDone: {
            var json = JSON.parse(result)
            if (ok && typeof json.url !== 'undefined') {
                if (root.text.length > 0 && root.text.substring(root.text.substring(root.text.length - 1, 1) !== ' '))
                    root.text += ' '
                root.text += json.url
                var media = []
                root.media = media
                root.message = 'Uploaded!'
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
            'key': '73972f9564679cf9fdd6fddd7fda610f'
            , 'message': ''
            , 'media': root.media[0]
        }
        uploader.upload('http://api.twitpic.com/2/upload.json', parameters)
    }
}

