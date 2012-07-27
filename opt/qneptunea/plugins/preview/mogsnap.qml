import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['mogsnap.jp']

    function load(url, domain) {
        var id = url.substring('http://mogsnap.jp/'.length);
        getMogSnapImageUrl(url, function(ret){ root.thumbnail = ret[0]; root.detail = ret[1] });
        return id.length > 0;
    }

    function getMogSnapImageUrl(url, callback) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                        console.debug(request.getAllResponseHeaders());
                    } else if ( request.readyState === 4 && request.status === 200 ) {
                        var re = new RegExp("http://(twitpic|yfrog).com/[0123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ]*");
                        var picurl = request.responseText.match(re).shift();
                        console.debug(picurl);
                        var id = '';

                        var a = picurl.split('/');
                        a.shift() // http:
                        a.shift() // ' ' (blank)
                        var picdomain = a.shift() // domainname
                        //console.debug("picdomain is ".concat(picdomain));

                        var b = new Array();

                        switch(picdomain) {
                        case 'twitpic.com': {
                            id = picurl.substring('http://twitpic.com/'.length)
                            b[0] = 'http://twitpic.com/show/thumb/'.concat(id);
                            b[1] = 'http://twitpic.com/show/large/'.concat(id);
                            break;
                        }
                        case 'yfrog.com': {
                            id = picurl.substring('http://yfrog.com/'.length)
                            b[0] = 'http://yfrog.com/'.concat(id).concat(':small');
                            b[1] = 'http://yfrog.com/'.concat(id).concat(':medium');
                            break;
                        }
                        }
                        //console.debug(b[0]);
                        //console.debug(b[1]);
                        callback(b);
                    }
                }
        request.send();
    }
}
