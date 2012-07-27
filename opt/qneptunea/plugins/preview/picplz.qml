import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['picplz.com']

    function load(url, domain) {
        var id = url.substring('http://picplz.com/'.length)
        root.thumbnail = 'http://picplz.com/'.concat(id).concat('/thumb/')
        root.detail = 'http://picplz.com/'.concat(id).concat('/thumb/400')
        return id.length > 0
    }
}
