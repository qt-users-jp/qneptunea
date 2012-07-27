import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['streamzoo.com']

    function load(url, domain) {
        var id = url.substring('http://streamzoo.com/i/'.length);
        getStreamzooImageUrl(url, function(ret){ root.thumbnail = ret; root.detail = ret });
        return id.length > 0;
    }

    function getStreamzooImageUrl(url, callback) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                        console.debug(request.getAllResponseHeaders());
                    } else if ( request.readyState === XMLHttpRequest.DONE) {
                        var re = new RegExp(/(http:\/\/cdn\.streamzoo\.com\/si_.[^"]*)/)
                        // Exception URL non-image post (text, sound, video). show alternative image
                        var excpurl = 'image://theme/icon-m-common-fault'

                        if (request.status === 200) {
                            if(re(request.responseText)) {
                                callback(RegExp.$1)
                            } else {
                                callback(excpurl)
                            }
                        } else {
                            callback(excpurl)
                        }
                    }
                }
        request.send();
    }
}

