import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['i.imgur.com', 'imgur.com']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id;

        switch(domain) {
        case 'i.imgur.com': {
            id = url.substring('http://i.imgur.com/'.length)
            root.thumbnail = 'http://i.imgur.com/'.concat(id.replace(/\./, 's.'))
            root.detail = url
            break;
        }
        case 'imgur.com': {
            id = url.substring('http://imgur.com/'.length)
            var re = new RegExp(/gallery.*/)
            if(re.test(id)) { id = id.split('/').pop() }
            getImgurPhotoUrl('http://api.imgur.com/2/image/'.concat(id).concat('.json'))
            break;
        }
        }
        return id.length > 0;
    }

    function getImgurPhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "application/json");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE )
                        if( request.status === 200 ) {
                            var jsonobj = JSON.parse(request.responseText);
                            root.thumbnail = jsonobj.image.links.small_square;
                            root.detail = jsonobj.image.links.original;
                        } else {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                        }
                }
        request.send();
    }
}
