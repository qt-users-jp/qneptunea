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
import 'sha1.js' as Sha1

GenericPreviewPlugin {
    id: root
    type: 'slideshare'
    domains: ['www.slideshare.net']

    property string api_key: 'k31SJf4M'
    property string sharedsecret: 'dailbs8X'

    property XmlListModel model: XmlListModel {
        id: model
        query: '/Slideshow'

        XmlRole { name: 'ID'; query: 'ID/string()' }
        XmlRole { name: 'ThumbnailURL'; query: 'ThumbnailURL/string()' }
    }

    states: [
        State {
            when: model.count === 1
            PropertyChanges {
                target: root
                thumbnail: 'http:'.concat(model.get(0).ThumbnailURL)
                _id: model.get(0).ID
            }
        }
    ]
    function load(url, domain) {
        var base_url = 'http://www.slideshare.net/api/2/get_slideshow'
        var param = {'api_key': root.api_key}
        param.slideshow_url = url
        var ts = new Date()
        param.ts = ts.getTime() / 1000
        param.hash = Sha1.hex_sha1(root.sharedsecret.concat(param.ts))

        var arr = new Array()
        for (var i in param) {
            arr.push(i.concat('=').concat(param[i]))
        }

        model.source = base_url.concat('?').concat(arr.join('&'))
        return true
    }
}
