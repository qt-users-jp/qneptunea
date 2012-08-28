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

import QNeptunea.Tweet 1.0
import QNeptunea 1.0

TweetPlugin {
    id: root
    name: qsTr('Upload media to Posterous')
    icon: './posterous/posterous.png'

    enabled: root.media.length > 0

    property variant uploader: PhotoUploader {
        id: uploader
        verifyCredentialsFormat: 'json'

        onDone: {
            var json = JSON.parse(result)
            if (ok && typeof json.url !== 'undefined') {
                if (root.text.length > 0 && root.text.substring(root.text.substring(root.text.length - 1, 1) !== ' '))
                    root.text += ' '
                root.text += json.url
                var media = []
                root.media = media
                root.message = qsTr('Uploaded!')
            } else {
                root.message = result
            }

            root.loading = false
        }
    }

    function exec() {
        if (root.media.length !== 1) return;

        root.loading = true

        var parameters = {
            'message': ''
            , 'media': root.media[0]
        }
        uploader.upload('http://posterous.com/api2/upload.json', parameters)
    }
}

