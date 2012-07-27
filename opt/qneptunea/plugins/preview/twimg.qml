import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['p.twimg.com', 'a0.twimg.com']

    function load(url, domain) {
        root.thumbnail = url
        root.detail = url
        return true
    }
}
