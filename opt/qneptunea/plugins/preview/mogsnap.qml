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
    domains: ['mogsnap.jp']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id = url.substring('http://mogsnap.jp/'.length)
        getMogSnapImageUrl(url)
        return id.length > 0
    }

    function getMogSnapImageUrl(url) {
        var request = new XMLHttpRequest()
        request.open('GET', url)
        request.setRequestHeader("Content-Type", "text/xml")
        request.onreadystatechange = function() {
                    if ( request.readyState === 4 && request.status === 200 ) {
                        var re = new RegExp("http://(twitpic|yfrog).com/[0-9a-zA-Z]*")
                        var picurl = request.responseText.match(re).shift()
                        var _id

                        var a = picurl.split('/')
                        a.shift() // http:
                        a.shift() // ' ' (blank)
                        var picdomain = a.shift() // domainname

                        switch(picdomain) {
                        case 'twitpic.com': {
                            _id = picurl.substring('http://twitpic.com/'.length)
                            root.thumbnail = 'http://twitpic.com/show/thumb/'.concat(_id)
                            root.detail = 'http://twitpic.com/show/large/'.concat(_id)
                            break
                        }
                        case 'yfrog.com': {
                            _id = picurl.substring('http://yfrog.com/'.length)
                            root.thumbnail = 'http://yfrog.com/'.concat(_id).concat(':small')
                            root.detail = 'http://yfrog.com/'.concat(_id).concat(':medium')
                            break
                        }
                        default: {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                            break
                        }
                        }
                    }
                }
        request.send()
    }
}
