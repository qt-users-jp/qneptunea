import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['img.ly']

    function load(url, domain) {
        var id = url.substring('http://img.ly/'.length)
        root.thumbnail = 'http://img.ly/show/thumb/'.concat(id)
        root.detail = 'http://img.ly/show/full/'.concat(id)
        return id.length > 0
    }
}
