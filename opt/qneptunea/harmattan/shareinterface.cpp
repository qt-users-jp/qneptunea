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

#include "shareinterface.h"

#include <QtCore/QDebug>
#include <QtDBus/QDBusInterface>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>

class ShareInterface::Private
{
public:
    QString url;
    QString mimeType;
    QString title;
    QString description;
};

ShareInterface::ShareInterface(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
}

ShareInterface::~ShareInterface()
{
    delete d;
}

const QString &ShareInterface::url() const
{
    return d->url;
}

void ShareInterface::setUrl(const QString &url)
{
    if (d->url == url) return;
    d->url = url;
    emit urlChanged(url);
}

const QString &ShareInterface::mimeType() const
{
    return d->mimeType;
}

void ShareInterface::setMimeType(const QString &mimeType)
{
    if (d->mimeType == mimeType) return;
    d->mimeType = mimeType;
    emit mimeTypeChanged(mimeType);
}

const QString &ShareInterface::title() const
{
    return d->title;
}

void ShareInterface::setTitle(const QString &title)
{
    if (d->title == title) return;
    d->title = title;
    emit titleChanged(title);
}

const QString &ShareInterface::description() const
{
    return d->description;
}

void ShareInterface::setDescription(const QString &description)
{
    if (d->description == description) return;
    d->description = description;
    emit descriptionChanged(description);
}

void ShareInterface::share()
{
    MDataUri uri;
    uri.setMimeType(d->mimeType);
    uri.setTextData(d->url);
    if (!d->title.isNull())
        uri.setAttribute("title", d->title);
    if (!d->description.isNull())
        uri.setAttribute("description", d->description);
    if (uri.isValid()) {
        ShareUiInterface shareIf("com.nokia.ShareUi");
        if (shareIf.isValid())
            shareIf.share(QStringList() << uri.toString());
    }
}
