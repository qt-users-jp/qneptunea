import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['fxc.am']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://fxc.am/p/'.length)
        getFxcPhotoUrl(url);
        return id.length > 0;
    }

    function getFxcPhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE ) {
                        if ( request.status === 200 ) {
                            var re = new RegExp(/(https?:\/\/img\.fxc\.am\/thumbs[^'"]*)/)

                            if(re.test(request.responseText)) {
                                var picurl = RegExp.$1
                                root.thumbnail = picurl
                                root.detail = picurl.replace(/thumbs/, 'scaled').replace(/\/keep640/, '')
                            } else {
                                root.thumbnail = root.excpurl;
                                root.detail = root.excpurl;
                            }
                        } else {
                            root.thumbnail = root.excpurl;
                            root.detail = root.excpurl;
                        }
                    }
                }
        request.send();
    }
}
