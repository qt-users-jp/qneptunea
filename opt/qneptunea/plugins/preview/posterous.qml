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
import QNeptunea.Preview 1.0

ImagePlugin {
    id: root
    domains: ['post.ly']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://%1/'.arg(domain).length)
        var apiurl = 'http://posterous.com/api/getpost?id=%1'.arg(id)
        getPosterousPhotoUrl(apiurl)
        return id.length > 0
    }

    function getPosterousPhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "text/xml");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE ) {
                        if ( request.status === 200 ) {
                            var xml = request.responseXML.documentElement
                            var rootNode = xml.childNodes[1].childNodes[19]
                            var nodeLength = rootNode.childNodes.length

                            root.detail = rootNode.childNodes[3].childNodes[1].childNodes[0].nodeValue
                            if (nodeLength > 6 ) {
                                var thumbTag = rootNode.childNodes[5].nodeName
                                if (thumbTag === 'thumb') {
                                    root.thumbnail = rootNode.childNodes[5].childNodes[1].childNodes[0].nodeValue
                                } else {
                                    root.thumbnail = root.detail
                                }
                            } else {
                                root.thumbnail = root.detail
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
