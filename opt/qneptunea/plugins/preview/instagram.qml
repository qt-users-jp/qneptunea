import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['instagr.am']

    function load(url, domain) {
        var id = url.substring('http://instagr.am/p/'.length).split('/').shift()
        root.thumbnail = 'http://instagr.am/p/'.concat(id).concat('/media?size=t')
        root.detail = 'http://instagr.am/p/'.concat(id).concat('/media?size=l')
        return id.length > 0
    }
}
