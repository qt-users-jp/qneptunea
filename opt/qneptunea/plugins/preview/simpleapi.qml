import QtQuick 1.1
import QNeptunea.Preview 1.0

WebPreviewPlugin {
    id: root
    domains: ['img.simpleapi.net']

    function load(url, domain) {
        var id = url.substring('http://img.simpleapi.net/small/'.length)
        root.thumbnail = url
        root.detail = id
    }
}
