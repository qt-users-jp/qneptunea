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

import QNeptunea.Service 1.0

ServicePlugin {
    id: root
    service: '+ Pocket'
    icon: 'getpocket.png'

    property string api: 'https://readitlaterlist.com/v2/add'
    property string apikey: 'c95TIV28g7177l4f1bda1b9v7dp3q62b'

    function matches(url) {
        return settings.readData('getpocket.com/username', '').length > 0 && settings.readData('getpocket.com/password', '').length > 0
    }

    function open(link, parameters, feedback) {
        var username = settings.readData('getpocket.com/username', '')
        var password = settings.readData('getpocket.com/password', '')
        if (username.length == 0 || password.length == 0) {
            pageStack.push(settingsPage, {'currentTab': 'plugins'})
            return
        }

        root.loading = true
        var url = api.concat('?apikey=').concat(apikey).concat('&username=').concat(username).concat('&password=').concat(password).concat('&url=').concat(link).concat('&title=').concat('@').concat(parameters.user.screen_name).concat(' ').concat(parameters.text)
        if (typeof parameters.id_str !== 'undefined')
            url = url.concat('&ref_id=').concat(parameters.id_str)
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.onreadystatechange = function() {
                    request.onreadystatechange = function() {
                                switch (request.readyState) {
                                case XMLHttpRequest.HEADERS_RECEIVED:
                                    break
                                case XMLHttpRequest.LOADING:
                                    break
                                case XMLHttpRequest.DONE: {
                                    root.result = (request.status == 200)
                                    if (root.result) {
                                        root.message = qsTr('Done!')
                                    } else {
                                        root.message = request.responseText
                                    }
                                    root.loading = false
                                    break }
                                case XMLHttpRequest.ERROR: {
                                    root.result = false
                                    root.message = request.responseText
                                    root.loading = false
                                    break }
                                }
                            }
                }
        request.send();
    }
}
