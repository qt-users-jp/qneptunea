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
import Twitter4QML 1.1

ListModel {
    id: root
    property string key

    function add(value) {
        for (var i = 0; i < root.count; i++) {
            if (value == root.get(i).key) {
                root.move(i, 0, 1)
                return
            }
        }
        root.insert(0, {'key': value})
    }

    property Timer time: Timer {
        running: true
        repeat: false
        interval: 500
        onTriggered: readData()
    }

    function readData() {
        var values = settings.readData(root.key, '').split(',')
        for (var i = 0; i < values.length; i++) {
            if (values[i].length > 0)
                root.append( {'key': values[i]} )
        }
    }

    Component.onDestruction: {
        if (oauth.state === OAuth.Authorized) {
            var values = []
            for (var i = 0; i < root.count && i < 100; i++) {
                if (root.get(i).key.length > 0)
                    values.push(root.get(i).key)
            }
            console.debug(values)
            settings.saveData(root.key, values.join(','))
        }
    }

    property Connections connections: Connections {
        target: oauth
        onStateChanged: {
            if (oauth.state === OAuth.Unauthorized) {
                console.debug('oauth.state', oauth.state)
                settings.saveData(root.key, '')
            }
        }
    }
}
