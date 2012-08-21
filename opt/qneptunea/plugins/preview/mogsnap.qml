import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['mogsnap.jp']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://mogsnap.jp/'.length)
        getMogSnapImageUrl(url)
        return id.length > 0
    }

    function getMogSnapImageUrl(url) {
        var request = new XMLHttpRequest()
        request.open('GET', url)
        request.setRequestHeader("Content-Type", "text/xml")
        request.onreadystatechange = function() {
                    if ( request.readyState === 4 && request.status === 200 ) {
                        var re = new RegExp("http://(twitpic|yfrog).com/[0-9a-zA-Z]*")
                        var picurl = request.responseText.match(re).shift()
                        var _id

                        var a = picurl.split('/')
                        a.shift() // http:
                        a.shift() // ' ' (blank)
                        var picdomain = a.shift() // domainname

                        switch(picdomain) {
                        case 'twitpic.com': {
                            _id = picurl.substring('http://twitpic.com/'.length)
                            root.thumbnail = 'http://twitpic.com/show/thumb/'.concat(_id)
                            root.detail = 'http://twitpic.com/show/large/'.concat(_id)
                            break
                        }
                        case 'yfrog.com': {
                            _id = picurl.substring('http://yfrog.com/'.length)
                            root.thumbnail = 'http://yfrog.com/'.concat(_id).concat(':small')
                            root.detail = 'http://yfrog.com/'.concat(_id).concat(':medium')
                            break
                        }
                        default: {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                            break
                        }
                        }
                    }
                }
        request.send()
    }
}
