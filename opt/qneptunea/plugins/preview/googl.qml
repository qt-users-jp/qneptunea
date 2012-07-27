import QtQuick 1.1
import QNeptunea.Preview 1.0

UrlShortenerPlugin {
    id: root
    domains: ['goo.gl']

    function load(url, domain) {
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            switch (request.readyState) {
            case XMLHttpRequest.HEADERS_RECEIVED:
                break;
            case XMLHttpRequest.LOADING:
                break;
            case XMLHttpRequest.DONE:
                root.url = JSON.parse(request.responseText).longUrl
                break
            case XMLHttpRequest.ERROR:
                break;
            }
        }

        request.open('GET', 'https://www.googleapis.com/urlshortener/v1/url?shortUrl='.concat(url));
        request.send();
        return true
    }
}

