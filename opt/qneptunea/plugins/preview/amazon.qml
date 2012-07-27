import QtQuick 1.1
import QNeptunea.Preview 1.0

WebPreviewPlugin {
    id: root
    domains: ['www.amazon.com', 'www.amazon.co.jp', 'www.amazon.co.uk']

    function load(url, domain) {
        var arr = url.split('/')
        var asin = ''
//        console.debug(arr, arr.indexOf('product'))
        if (arr.indexOf('product') > -1)
            asin = arr[arr.indexOf('product') + 1]
        else if (arr.indexOf('dp') > -1)
            asin = arr[arr.indexOf('dp') + 1]
        else if (arr.indexOf('ASIN') > -1)
            asin = arr[arr.indexOf('ASIN') + 1]
        else {
            console.debug('asin not found in', url, arr)
            return false
        }

        if (asin.indexOf('?') > -1)
            asin = asin.substring(asin.indexOf('?'))
        root.thumbnail = 'http://images.amazon.com/images/P/'.concat(asin).concat('.png')
//        console.debug(root.thumbnail)
        root.detail = url
        return true
    }
}
