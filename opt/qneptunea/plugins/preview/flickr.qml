import QtQuick 1.1
import QNeptunea.Preview 1.0

//Flickr API Key of ’Flickr plugin for QNeptunea’ is "4ca8a968c911a0f96843693d41b993a2" Secret is not used.
//decoding base58 code function is written by Taiyo (http://d.hatena.ne.jp/t_trace/20090706/p1)

ImagePlugin {
    id: root
    domains: ['www.flickr.com', 'flic.kr']

    function load(url, domain) {
        var id = '';
        var phototype = '';
        var apiurl = '';
        var apikey = '4ca8a968c911a0f96843693d41b993a2';

        console.debug("Source URL is ".concat(url));
        var a = url.split('/');
        a.shift() // http:
        a.shift() // ' ' (blank)
        a.shift() // domainname

        switch(domain) {
        case 'www.flickr.com': {
            a.shift(); // photos
            a.shift(); // usrid
            id = a.shift(); // photo id
            console.debug("Photo ID is " + id);
            phototype = a.shift(); // digits id or blank

            // phototype ' '(blank) is PhotoStream, not photo.
            if(phototype !== '') {
                return false
            } else {
                apiurl = 'http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key='.concat(apikey).concat('&format=json&nojsoncallback=1&photo_id=').concat(id);
                getFlickrPhotoUrl(apiurl, function(ret){ root.thumbnail = ret[0]; root.detail = ret[1];});
            }

            break;
        }
        case 'flic.kr': {
            phototype = a.shift(); // p or ps
            // phototype 'ps' is PhotoStream, not photo.
            if(phototype === 'p') {
                id = base58_decode(url.substring('http://flic.kr/p/'.length));
                console.debug("Photo ID is " + id);
                apiurl = 'http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key='.concat(apikey).concat('&format=json&nojsoncallback=1&photo_id=').concat(id);
                getFlickrPhotoUrl(apiurl, function(ret){ root.thumbnail = ret[0]; root.detail = ret[1];});
            } else {
                return false
            }
            break;
        }
        }
        return true
    }

    //Fixme: Better and original implementation is welcomed!!
    function base58_decode( snipcode ) {
        var alphabet = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ' ;
        var num = snipcode.length ;
        var decoded = 0 ;
        var multi = 1 ;
        for ( var i = (num-1) ; i >= 0 ; i-- )
        {
            decoded = decoded + multi * alphabet.indexOf( snipcode[i] ) ;
            multi = multi * alphabet.length ;
        }
        return decoded;
    }

    function getFlickrPhotoUrl(url, callback) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    console.debug(request.readyState);
                    console.debug(request.status);
                    var a = new Array(2)
                    if ( request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                        console.debug(request.getAllResponseHeaders());
                    } else if ( request.readyState === XMLHttpRequest.DONE && request.status === 200 ) {
                        console.debug(request.responseText);
                        var jsonobj = JSON.parse(request.responseText);
                        a[0] = jsonobj.sizes.size[1].source;
                        a[1] = jsonobj.sizes.size[5].source;
                        console.debug("DEBUG: Thumbnail pic url is " + a[0]);
                        console.debug("DEBUG: Detail pic url is " + a[1]);
                        callback(a);
                    }
                }
        request.send();
    }
}
