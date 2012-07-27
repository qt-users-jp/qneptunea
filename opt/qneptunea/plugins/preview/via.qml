import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['via.me']

    property string clientid: 'p0u8jmf1rtrz848vhmgs2kzy'
    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://via.me/-'.length);
        console.debug('id is '.concat(id))
        var apiurl = 'http://api.via.me/v1/posts/'.concat(id).concat('?client_id=').concat(root.clientid);
        getViamePhotoUrl(apiurl);
        return id.length > 0;
    }

    function getViamePhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "application/json");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE ) {
                        if ( request.status === 200 ) {
                            var jsonobj = JSON.parse(request.responseText);
                            root.thumbnail = jsonobj.response.post.thumb_url;
                            root.detail = jsonobj.response.post.media_url;
                        }
                        else {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                        }
                    }
                }
        request.send();
    }
}
