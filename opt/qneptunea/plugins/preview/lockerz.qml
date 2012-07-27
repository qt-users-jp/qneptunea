import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['lockerz.com']

    function load(url, domain) {
        var id = url.substring('http://lockerz.com/s/'.length)
        root.thumbnail = 'http://api.plixi.com/api/tpapi.svc/imagefromurl?size=small&url='.concat(url)
        root.detail = 'http://api.plixi.com/api/tpapi.svc/imagefromurl?size=medium&url='.concat(url)
        return id.length > 0
    }
}
