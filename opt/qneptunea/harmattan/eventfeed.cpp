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

#include "eventfeed.h"

#include <meegotouchevents/meventfeed.h>

class EventFeed::Private
{
public:
    QString icon;
    QString title;
    QString body;
    QStringList imageList;
    QDateTime timestamp;
    QString footer;
    bool video;
    QUrl url;
    QString sourceName;
    QString sourceDisplayName;
};

EventFeed::EventFeed(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
    d->video = false;
}

EventFeed::~EventFeed()
{
    delete d;
}

qlonglong EventFeed::add()
{
    return MEventFeed::instance()->addItem(d->icon, d->title, d->body, d->imageList, d->timestamp, d->footer, d->video, d->url, d->sourceName, d->sourceDisplayName);
}

//void EventFeed::remove(qlonglong id)
//{
//    MEventFeed::instance()->removeItem(id);
//}

const QString &EventFeed::icon() const
{
    return d->icon;
}

void EventFeed::setIcon(const QString &icon)
{
    if (d->icon == icon) return;
    d->icon = icon;
    emit iconChanged(icon);
}

const QString &EventFeed::title() const
{
    return d->title;
}

void EventFeed::setTitle(const QString &title)
{
    if (d->title == title) return;
    d->title = title;
    emit titleChanged(title);
}

const QString &EventFeed::body() const
{
    return d->body;
}

void EventFeed::setBody(const QString &body)
{
    if (d->body == body) return;
    d->body = body;
    emit bodyChanged(body);
}

const QStringList &EventFeed::imageList() const
{
    return d->imageList;
}

void EventFeed::setImageList(const QStringList &imageList)
{
    if (d->imageList == imageList) return;
    d->imageList = imageList;
    emit imageListChanged(imageList);
}

const QDateTime &EventFeed::timestamp() const
{
    return d->timestamp;
}

void EventFeed::setTimestamp(const QDateTime &timestamp)
{
    if (d->timestamp == timestamp) return;
    d->timestamp = timestamp;
    emit timestampChanged(timestamp);
}

const QString &EventFeed::footer() const
{
    return d->footer;
}

void EventFeed::setFooter(const QString &footer)
{
    if (d->footer == footer) return;
    d->footer = footer;
    emit footerChanged(footer);
}

bool EventFeed::video() const
{
    return d->video;
}

void EventFeed::setVideo(bool video)
{
    if (d->video == video) return;
    d->video = video;
    emit videoChanged(video);
}

const QUrl &EventFeed::url() const
{
    return d->url;
}

void EventFeed::setUrl(const QUrl &url)
{
    if (d->url == url) return;
    d->url = url;
    emit urlChanged(url);
}

const QString &EventFeed::sourceName() const
{
    return d->sourceName;
}

void EventFeed::setSourceName(const QString &sourceName)
{
    if (d->sourceName == sourceName) return;
    d->sourceName = sourceName;
    emit sourceNameChanged(sourceName);
}

const QString &EventFeed::sourceDisplayName() const
{
    return d->sourceDisplayName;
}

void EventFeed::setSourceDisplayName(const QString &sourceDisplayName)
{
    if (d->sourceDisplayName == sourceDisplayName) return;
    d->sourceDisplayName = sourceDisplayName;
    emit sourceDisplayNameChanged(sourceDisplayName);
}
