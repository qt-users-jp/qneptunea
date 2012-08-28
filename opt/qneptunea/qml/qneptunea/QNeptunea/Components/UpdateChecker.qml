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
import com.nokia.meego 1.0

QueryDialog {
    id: root

    property string applicationName: 'QNeptunea'
    icon: 'file://usr/share/icons/hicolor/256x256/apps/qneptunea256.png'
    titleText: qsTr('New version available')
    message: qsTr('%1 version %2 is available.\nDo you want to download the package?\ndev.qtquick.me/projects/qneptunea/files\n\nIf installation fails, clear brower cache\n$ rm /home/user/.grob/cache/http*/*\nThen download the package again.').arg(root.applicationName).arg(root.version)

    platformStyle: QueryDialogStyle { messageFontPixelSize: 22 }
    property string version
    property url download

    acceptButtonText: qsTr('Download')
    rejectButtonText: qsTr('No thanks')

    onAccepted: ActionHandler.openUrlExternally(root.download)

    Timer {
        running: !currentVersion.trusted
        repeat: false
        interval: 5000
        onTriggered: check()
    }

    function check() {
        if (constants.updateCheckDisabled) return
        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            switch (request.readyState) {
            case XMLHttpRequest.HEADERS_RECEIVED:
                break;
            case XMLHttpRequest.LOADING:
                break;
            case XMLHttpRequest.DONE: {
                var text = request.responseText
                if (text.match(/<a href="(\/attachments\/download\/[0-9]+\/qneptunea_([0-9]+\.[0-9]+\.[0-9]+)_armel\.deb)"/)) {
                    root.download = 'http://dev.qtquick.me'.concat(RegExp.$1)
                    root.version = RegExp.$2
                    if (currentVersion.version < root.version) {
                        root.open()
                    }
                } else {
                    console.debug(text)
                }
            }
                break
            case XMLHttpRequest.ERROR:
                break;
            }
        }

        request.open('GET', 'http://dev.qtquick.me/projects/'.concat(applicationName.toLowerCase()).concat('/files'));
        request.send();
    }
}
