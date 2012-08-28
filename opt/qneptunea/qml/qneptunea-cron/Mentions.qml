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
import Twitter4QML 1.0
import QNeptunea 1.0

MentionsModel {
    id: model
    property bool done: false

    count: 200
    sortKey: 'id_str'
    since_id: settings.readData('MentionsPage/maxReadIdStr', '')

    onLoadingChanged: {
        if (loading) {
            //                console.debug('since_id', since_id)
        } else {
            if (model.size > 0 && model.get(0).id_str !== settings.readData('MentionsPage/maxLoadedIdStr', '')) {
                var component = notification.createObject(window)
                component.eventType = 'qneptunea.mentions'
                component.image = settings.readData('Theme/NotificationIconForMentions', 'icon-m-service-qneptunea-mention')
                window.clearNotifications(component)
                var item = model.get(0)
                component.summary = item.user.name.concat(' @').concat(item.user.screen_name)
                if (model.size == 1) {
                    component.body = '1 new mention'
                } else {
                    component.body = model.size + ' new mentions'
                }
                component.identifier = 'mentions'
                component.count = model.size

                if (component.publish() && settings.readData('Notifications/HapticsFeedback', false))
                    rumbleEffect.start()
                settings.saveData('MentionsPage/maxLoadedIdStr', model.get(0).id_str)
            }
            model.done = true
        }
    }

    onFiltering: if (window.filter(value)) model.filter()
}

