import QtQuick 1.1
import QNeptunea.Preview 1.0

//movapic is "Keitai Hyakkei"
ImagePlugin {
    id: root
    domains: ['movapic.com']

    function load(url, domain){
        var id = url.substring('http://movapic.com/pic/'.length)
        root.thumbnail = 'http://image.movapic.com/pic/s_'.concat(id).concat('.jpeg')
        root.detail = 'http://image.movapic.com/pic/m_'.concat(id).concat('.jpeg')
        return id.length > 0
    }
}
