import QNeptunea.Service 1.0
import QtQuick 1.1

ServicePlugin {
    id: root
    service: 'MS Translator V2'
    icon: 'mstranslator.png'

    property variant delegate

    function matches(url) {
        return settings.readData('microsofttranslator.com/client_id', '').length > 0 && settings.readData('microsofttranslator.com/client_secret', '').length > 0
    }

    function open(link, parameters, feedback) {
        root.delegate = feedback
        var client_id = settings.readData('microsofttranslator.com/client_id', '')
        var client_secret = settings.readData('microsofttranslator.com/client_secret', '')

        var url = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
        var query = 'grant_type=client_credentials&client_id='.concat(client_id).concat('&client_secret=').concat(escape(client_secret)).concat('&scope=').concat(escape('http://api.microsofttranslator.com'))

        var request = new XMLHttpRequest()
        request.open('POST', url)
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        request.onreadystatechange = function() {
                    request.onreadystatechange = function() {
//                                console.debug(request.readyState)
                                switch (request.readyState) {
                                case XMLHttpRequest.HEADERS_RECEIVED:
                                    break
                                case XMLHttpRequest.LOADING:
                                    break
                                case XMLHttpRequest.DONE:
                                    translate(JSON.parse(request.responseText).access_token, parameters.text)
                                    break
                                case XMLHttpRequest.ERROR:
                                    break
                                }
                            }
                }
        request.send(query)
    }


    function translate(accessToken, source) {
        var lang = LANG
        if (lang.indexOf('_') > -1)
            lang = lang.substring(0, lang.indexOf('_'))
        var url = 'http://api.microsofttranslator.com/v2/Http.svc/Translate?'.concat('text=').concat(encodeURIComponent(source)).concat('&to=').concat(lang)
        var request = new XMLHttpRequest()
        request.open('GET', url)
        request.setRequestHeader('Authorization', 'Bearer '.concat(accessToken))
        request.setRequestHeader("Content-type", "text/plain")
        request.onreadystatechange = function() {
                    request.onreadystatechange = function() {
//                                console.debug(request.readyState)
                                switch (request.readyState) {
                                case XMLHttpRequest.HEADERS_RECEIVED:
                                    break
                                case XMLHttpRequest.LOADING:
                                    break
                                case XMLHttpRequest.DONE: {
                                    console.debug(request.responseText)
                                    parser.xml = '<?xml version="1.0"?>\n'.concat(request.responseText).concat('\n')
                                    break }
                                case XMLHttpRequest.ERROR:
                                    break
                                }
                            }
                }
        request.send()
    }

    property XmlListModel parser: XmlListModel {
        id: parser
        namespaceDeclarations: "declare default element namespace 'http://schemas.microsoft.com/2003/10/Serialization/';"
        query: '/string'

        XmlRole { name: 'text'; query: './string()' }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                if (parser.count > 0) {
                    root.delegate.translated = parser.get(0).text
                }
            }
        }
    }
}
