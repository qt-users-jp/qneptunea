import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['p.twipple.jp']

    function load(url, domain) {
        var id = url.substring('http://p.twipple.jp/'.length)
        root.thumbnail = 'http://p.twipple.jp/show/thumb/'.concat(id)
        root.detail = 'http://p.twipple.jp/show/large/'.concat(id)
        return id.length > 0
    }
}
