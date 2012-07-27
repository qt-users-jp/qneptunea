import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['molo.me', 'molome.com', 'www.molo.me', 'www.molome.com']

    function load(url, domain) {
        var arr = url.split('/')
        var pictureCode = ''

        if (arr.indexOf('p') > -1)
            pictureCode = arr[arr.indexOf('p') + 1]
        else
            console.debug('pictureCode not found in', url, arr)

        if (pictureCode.indexOf('?') > -1)
            pictureCode = pictureCode.substring(pictureCode.indexOf('?'))
        root.thumbnail = 'http://p210x210.molo.me/'.concat(pictureCode).concat('_210x210')
        root.detail = 'http://molo.me/p/'.concat(pictureCode).concat('/preview')
        return pictureCode.length > 0
    }
}
