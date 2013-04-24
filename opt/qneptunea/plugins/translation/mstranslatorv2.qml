/* Copyright (c) 2012-2013 QNeptunea Project.
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
