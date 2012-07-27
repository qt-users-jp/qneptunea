import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['twitpic.com']

    function load(url, domain) {
        var id = url.substring('http://twitpic.com/'.length)
        root.thumbnail = 'http://twitpic.com/show/thumb/'.concat(id)
        root.detail = 'http://twitpic.com/show/large/'.concat(id)
        return id.length > 0
    }
}
