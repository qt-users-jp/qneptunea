/* Copyright (c) 2012 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QNeptunea.Service 1.0
import QtQuick 1.1

ServicePlugin {
    id: root
    service: 'Microsoft Translator'
    icon: 'mstranslator.png'

    property variant delegate

    function matches(url) {
        return settings.readData('microsofttranslator.com/client_id', 'qneptunea').length > 0 && settings.readData('microsofttranslator.com/client_secret', 'PEpfJi37mU8wBvvutyntOiX0VslIHuehGiFLgAbKLlw=').length > 0
    }

    function open(link, parameters, feedback) {
        root.loading = true
        root.delegate = feedback
        var client_id = settings.readData('microsofttranslator.com/client_id', 'qneptunea')
        var client_secret = settings.readData('microsofttranslator.com/client_secret', 'PEpfJi37mU8wBvvutyntOiX0VslIHuehGiFLgAbKLlw=')

        var url = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
        var query = 'grant_type=client_credentials&client_id='.concat(encodeURIComponent(client_id)).concat('&client_secret=').concat(encodeURIComponent(client_secret)).concat('&scope=').concat(encodeURIComponent('http://api.microsofttranslator.com'))

        var responseText = ''
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
                                    responseText = request.responseText
                                    break
                                case XMLHttpRequest.DONE:
                                    if (request.responseText.length > 0)
                                        responseText = request.responseText
                                    var json
                                    try {
                                        json = JSON.parse(responseText)
                                    } catch(e) {
                                        root.loading = false
                                        break
                                    }

                                    if (typeof json.access_token !== 'undefined') {
                                        translate(json.access_token, parameters.text)
                                    } else if (typeof json.error !== 'undefined') {
                                        root.loading = false
                                    } else {
                                        root.loading = false
                                    }

                                    break
                                case XMLHttpRequest.ERROR:
                                    root.loading = false
                                    break
                                }
                            }
                }
        request.send(query)
    }


    function translate(accessToken, source) {
        var message = qsTr('en (Please translate this "en" to closest langage code in http://msdn.microsoft.com/en-us/library/hh456380.)')
        var lang = settings.readData('microsofttranslator.com/to', message.substring(0, message.indexOf(' (')))
        var url = 'http://api.microsofttranslator.com/v2/Http.svc/Translate?'.concat('text=').concat(encodeURIComponent(source)).concat('&to=').concat(lang)
        console.debug(url)

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
//                                    console.debug(request.responseText)
                                    parser.xml = '<?xml version="1.0"?>\n'.concat(request.responseText).concat('\n')
                                    break }
                                case XMLHttpRequest.ERROR:
                                    root.loading = false
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
                root.loading = false
            } else if (status === XmlListModel.Error) {
                root.loading = false
            }
        }
    }
}
