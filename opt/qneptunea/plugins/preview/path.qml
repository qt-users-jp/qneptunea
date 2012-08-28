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
