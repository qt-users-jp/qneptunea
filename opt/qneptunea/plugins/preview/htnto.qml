import QtQuick 1.1
import QNeptunea.Preview 1.0

UrlShortenerPlugin {
    id: root
    domains: ['htn.to']

    function load(url, domain) {
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            switch (request.readyState) {
            case XMLHttpRequest.HEADERS_RECEIVED:
                root.url = request.getResponseHeader("Location")
                break;
            case XMLHttpRequest.LOADING:
                break;
            case XMLHttpRequest.DONE:
//                console.debug(request.responseText)
                break
            case XMLHttpRequest.ERROR:
                break;
            }
        }

        request.open('GET', url);
        request.send();
        return true
    }
}

