import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['yfrog.com']

    function load(url, domain) {
        var id = url.substring('http://yfrog.com/'.length)
        root.thumbnail = 'http://yfrog.com/'.concat(id).concat(':small')
        root.detail = 'http://yfrog.com/'.concat(id).concat(':medium')
        return id.length > 0
    }
}

