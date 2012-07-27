import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['photozou.jp']

    function load(url, domain) {
        var id = url.split('/').pop(); // http://photozou.jp/<userid?>/<photoid>
        root.thumbnail = 'http://photozou.jp/p/thumb/'.concat(id)
        root.detail = 'http://photozou.jp/p/img/'.concat(id)
        return id.length > 0
    }
}
