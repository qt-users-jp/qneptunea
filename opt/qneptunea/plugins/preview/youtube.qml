import QtQuick 1.1
import QNeptunea.Preview 1.0

GenericPreviewPlugin {
    id: root
    type: 'youtube'
    domains: ['www.youtube.com', 'youtube.com', 'm.youtube.com', 'youtu.be', 'y2u.be']

    function load(url, domain) {
        var id = ''
        var parameters
        switch (domain) {
        case 'youtu.be':
        case 'y2u.be':
            id = url.substring(domain.length + 8).split('?')[0]
            break
        default:
            parameters = url.split('?')
            parameters.shift()
            parameters = parameters.join('?').split('&')
            for (var i = 0; i < parameters.length; i++) {
                if (parameters[i].substring(0, 2) === 'v=') {
                    id = parameters[i].substring(2)
                    break
                }
            }
            break
        }


        root.thumbnail = 'http://img.youtube.com/vi/'.concat(id).concat('/1.jpg')
        root._id = id
        return id.length > 0
    }
}
