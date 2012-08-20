import QtQuick 1.1
import QNeptunea.Preview 1.0
import 'sha1.js' as Sha1

GenericPreviewPlugin {
    id: root
    type: 'slideshare'
    domains: ['www.slideshare.net']

    property string api_key: 'k31SJf4M'
    property string sharedsecret: 'dailbs8X'

    property XmlListModel model: XmlListModel {
        id: model
        query: '/Slideshow'

        XmlRole { name: 'ID'; query: 'ID/string()' }
        XmlRole { name: 'ThumbnailURL'; query: 'ThumbnailURL/string()' }
    }

    states: [
        State {
            when: model.count === 1
            PropertyChanges {
                target: root
                thumbnail: 'http:'.concat(model.get(0).ThumbnailURL)
                _id: model.get(0).ID
            }
        }
    ]
    function load(url, domain) {
        var base_url = 'http://www.slideshare.net/api/2/get_slideshow'
        var param = {'api_key': root.api_key}
        param.slideshow_url = url
        var ts = new Date()
        param.ts = ts.getTime() / 1000
        param.hash = Sha1.hex_sha1(root.sharedsecret.concat(param.ts))

        var arr = new Array()
        for (var i in param) {
            arr.push(i.concat('=').concat(param[i]))
        }

        model.source = base_url.concat('?').concat(arr.join('&'))
        return true
    }
}
