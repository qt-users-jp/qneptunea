import QtQuick 1.1
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['path.com']

    function load(url, domain) {
        var id = url.substring('http://path.com/p/'.length);
        getPathImageUrl(url, function(ret){ root.thumbnail = ret[0]; root.detail = ret[1] });
        return id.length > 0;
    }

    function getPathImageUrl(url, callback) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                        console.debug(request.getAllResponseHeaders());
                    } else if ( request.readyState === 4 && request.status === 200 ) {
                        var re = new RegExp("<meta name=\"og:image\" content=\"https?://[^\"]*");
                        var grep = '';
                        var picurl = '';

                        if (re.test(request.responseText)) {
                            grep = request.responseText.match(re).shift();
                            picurl = grep.split('"').pop();
                        } else {
                            // case of simple text only, showing profile image of tweet owner.
                            grep = request.responseText.match(/<div class="user-avatar tooltip-target">[^>]*/g).shift();
                            var a = grep.split('"');
                            a.shift();
                            a.shift();
                            a.shift();
                            picurl = a.shift();
                        }

                        console.debug("picurl is ".concat(picurl));

                        var b = picurl.split('/');
                        b.shift() // http(s):
                        b.shift() // ' ' (blank)
                        var picdomain = b.shift() // domainname
                        console.debug("picdomain is ".concat(picdomain));

                        var c = new Array();

                        switch(picdomain.match(/mzstatic.com|amazonaws.com|maps.googleapis.com/).shift()) {
                        case 'mzstatic.com': {
                            c[0] = picurl.replace("100x100", "200x200");
                            c[1] = picurl.replace("100x100", "400x400");
                            break;
                        }
                        case 'amazonaws.com': {
                            c[0] = picurl.replace("/2x", "/1x");
                            c[1] = picurl;
                            break;
                        }
                        default: {
                            c[0] = picurl;
                            c[1] = picurl;
                            break;
                        }
                        }
                        console.debug(c[0]);
                        console.debug(c[1]);
                        callback(c);
                    }
                }
        request.send();
    }
}
