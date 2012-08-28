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

//decoding base58 code function is written by Taiyo (http://d.hatena.ne.jp/t_trace/20090706/p1)

ImagePlugin {
    id: root
    domains: ['www.flickr.com', 'flic.kr']

    property string apikey: '4ca8a968c911a0f96843693d41b993a2'
    property url excpurl: 'image://theme/icon-m-common-fault'

    function load(url, domain) {
        var id;
        var a = url.split('/');
        a.shift() // http:
        a.shift() // ' ' (blank)
        a.shift() // domainname

        switch(domain) {
        case 'www.flickr.com': {
            a.shift(); // photos
            a.shift(); // usrid
            id = a.shift(); // photo id
            break
        }
        case 'flic.kr': {
            a.shift() // p
            id = base58_decode(a.shift()).toString();
            break
        }
        }
        console.debug("Photo ID is " + id);
        var apiurl = 'http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key='.concat(root.apikey).concat('&format=json&nojsoncallback=1&photo_id=').concat(id);
        getFlickrPhotoUrl(apiurl);
        return id.length > 0;
    }

    //Fixme: Better and original implementation is welcomed!!
    function base58_decode( snipcode ) {
        var alphabet = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ' ;
        var num = snipcode.length ;
        var decoded = 0 ;
        var multi = 1 ;
        for ( var i = (num-1) ; i >= 0 ; i-- ) {
            decoded = decoded + multi * alphabet.indexOf( snipcode[i] ) ;
            multi = multi * alphabet.length ;
        }
        return decoded;
    }

    function getFlickrPhotoUrl(url) {
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.setRequestHeader("Content-Type", "application/json");
        request.onreadystatechange = function() {
                    if ( request.readyState === XMLHttpRequest.DONE ) {
                        if ( request.status === 200 ) {
                            var jsonobj = JSON.parse(request.responseText);
                            root.thumbnail = jsonobj.sizes.size[1].source;
                            root.detail = jsonobj.sizes.size[5].source;
                        }
                        else {
                            root.thumbnail = root.excpurl;
                            root.detail = root.excpurl;
                        }
                    }
                }
        request.send();
    }
}
