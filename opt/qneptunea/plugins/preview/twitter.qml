import QtQuick 1.1
import Twitter4QML 1.0
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['twitter.com']

    property int photoId
    property Status __status: Status {
        id: status
        onLoadingChanged: {
            if (loading) return
            console.debug('entities', entities)
        }

        onMediaChanged: {
            console.debug('media', typeof media, photoId)
            root.thumbnail = media[photoId - 1]
            root.detail = media[photoId - 1]
        }
    }

    function load(url, domain) {
        root.photoId = url.split('/')[7]
        status.id_str = url.split('/')[5]
        return true
    }
}
