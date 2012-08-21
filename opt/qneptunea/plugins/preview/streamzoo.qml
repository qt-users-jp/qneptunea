import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['streamzoo.com']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://streamzoo.com/i/'.length);
        getStreamzooImageUrl(url);
        return id.length > 0;
    }

    function getStreamzooImageUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE) {
                        var re = new RegExp(/(http:\/\/cdn\.streamzoo\.com\/si_.[^"]*)/)

                        if (request.status === 200) {
                            if(re.test(request.responseText)) {
                                root.thumbnail = RegExp.$1
                                root.detail = RegExp.$1
                            } else {
                                root.thumbnail = root.excpurl
                                root.detail = root.excpurl
                            }
                        } else {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                        }
                    }
                }
        request.send();
    }
}

