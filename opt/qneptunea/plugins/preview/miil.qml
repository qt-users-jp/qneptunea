import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['miil.me']

    function load(url, domain) {
        var id = url.substring('http://miil.me/p/'.length)
        root.thumbnail = url.concat('.jpeg?size=150')
        root.detail = url.concat('.jpeg?size=480')
        return id.length > 0
    }
}
