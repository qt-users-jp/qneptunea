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

QtObject {
    id: root
    property string version
    property bool trusted: true

    property Timer timer: Timer {
        running: true
        interval: 200
        repeat: false
        onTriggered: {
            checkVersion()
            if (!app.isDeveloper(oauth.screen_name))
                checkSource()
        }
    }

    function checkVersion() {
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
                    switch (request.readyState) {
                    case XMLHttpRequest.HEADERS_RECEIVED:
                        break;
                    case XMLHttpRequest.LOADING:
                        break;
                    case XMLHttpRequest.DONE: {
                        var qneptunea = false
                        var lines = request.responseText.split('\n')
                        for (var i = 0; i < lines.length; i++) {
                            var line = lines[i]
                            if (qneptunea) {
                                if (line.substring(0, 9) == 'Version: ') {
                                    root.version = line.substring(9)
                                    break
                                }
                            } else {
                                if (line == 'Package: qneptunea') {
                                    qneptunea = true
                                }
                            }
                        }
                    }
                    break
                    case XMLHttpRequest.ERROR:
                        break;
                    }
                }

        request.open('GET', 'file:///var/lib/dpkg/status');
        request.send();
    }

    function checkSource() {
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
                    switch (request.readyState) {
                    case XMLHttpRequest.HEADERS_RECEIVED:
                        break;
                    case XMLHttpRequest.LOADING:
                        break;
                    case XMLHttpRequest.DONE: {
                        var lines = request.responseText.split('\n')
                        for (var i = 0; i < lines.length; i++) {
                            var fields = lines[i].split(/ /)
                            if (fields[12] === 'qneptunea') {
                                root.trusted = (fields[1] === '19')
                                break
                            }
                        }
                    }
                    break
                    case XMLHttpRequest.ERROR:
                        break;
                    }
                }

        request.open('GET', 'file:///var/lib/aegis/refhashlist');
        request.send();
    }
}
