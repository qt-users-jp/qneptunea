import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['moby.to']

    function load(url, domain) {
        var id = url.substring('http://moby.to/'.length)
        root.thumbnail = 'http://moby.to/'.concat(id).concat(':square')
        root.detail = 'http://moby.to/'.concat(id).concat(':full')
        return id.length > 0
    }
}
