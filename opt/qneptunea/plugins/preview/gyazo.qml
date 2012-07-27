import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['gyazo.com']

    function load(url, domain) {
        var id = url.substring('http://gyazo.com/'.length)
        root.thumbnail = url.concat('.png')
        root.detail = url.concat('.png')
        return id.length > 0
    }
}
