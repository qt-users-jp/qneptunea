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
    domains: ['i.imgur.com', 'imgur.com']

    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id;

        switch(domain) {
        case 'i.imgur.com': {
            id = url.substring('http://i.imgur.com/'.length)
            root.thumbnail = 'http://i.imgur.com/'.concat(id.replace(/\./, 's.'))
            root.detail = url
            break;
        }
        case 'imgur.com': {
            id = url.substring('http://imgur.com/'.length)
            var re = new RegExp(/gallery.*/)
            if(re.test(id)) { id = id.split('/').pop() }
            getImgurPhotoUrl('http://api.imgur.com/2/image/%1.json'.arg(id))
            break;
        }
        }
        return id.length > 0;
    }

    function getImgurPhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "application/json");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE )
                        if( request.status === 200 ) {
                            var jsonobj = JSON.parse(request.responseText);
                            root.thumbnail = jsonobj.image.links.small_square;
                            root.detail = jsonobj.image.links.original;
                        } else {
                            root.thumbnail = root.excpurl
                            root.detail = root.excpurl
                        }
                }
        request.send();
    }
}
