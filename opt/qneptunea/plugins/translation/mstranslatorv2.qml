import QtQuick 1.1
import QNeptunea.Translation 1.0

TranslationPlugin {
    id: root
    service: 'Microsoft Translator V2'
    url: 'http://msdn.microsoft.com/en-us/library/dd576287.aspx'

    property string requestUrl: 'http://api.microsofttranslator.com/V2/Http.svc/Translate'
    property string api: 'A0D430A6168AF421931721F9AEE7B75E25409B50'
    property string contentType: 'text/html'
    function translate(richText, plainText, to, from) {
        var url = root.requestUrl
                        .concat('?appId=')
                        .concat(root.api)
                        .concat('&contentType=')
                        .concat(root.contentType)
                        .concat('&to=')
                        .concat(to)
        if (typeof from !== 'undefined')
            url = url.concat('&from=').concat(from)
        url = url.concat('&text=').concat(encodeURI(plainText.replace(/#/g, '')))

        console.debug(url)
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.onreadystatechange = function() {
                    request.onreadystatechange = function() {
                                console.debug(request.readyState)
                                console.debug(request.status)
                                switch (request.readyState) {
                                case XMLHttpRequest.HEADERS_RECEIVED:
                                    console.debug('XMLHttpRequest.HEADERS_RECEIVED', XMLHttpRequest.HEADERS_RECEIVED)
                                    break;
                                case XMLHttpRequest.LOADING:
                                    console.debug('XMLHttpRequest.LOADING', XMLHttpRequest.LOADING)
                                    break;
                                case XMLHttpRequest.DONE:
                                    console.debug('XMLHttpRequest.DONE', XMLHttpRequest.DONE)
                                    console.debug(request.responseText)
                                    root.result = decodeURI(request.responseText.replace(/<.*?>/g, '').replace(/&lt;/g, "<").replace(/&gt;/g, ">"))
//                                    console.debug(root.result)
//                                    console.debug(request.responseXML)
                                    break
                                case XMLHttpRequest.ERROR:
                                    console.debug('XMLHttpRequest.ERROR', XMLHttpRequest.ERROR)
                                    break;
                                }
                            }
                }
        request.send();
    }
}
