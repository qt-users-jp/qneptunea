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

#include "thumbnailer.h"

#include <QDebug>
#include <QtCore/QUrl>
#include <QtCore/QDir>
#include <QtCore/QFileInfo>
#include <QtCore/QCryptographicHash>

#define DEBUG() qDebug() << __PRETTY_FUNCTION__ << __LINE__

Thumbnailer::Thumbnailer()
    : QDeclarativeImageProvider(QDeclarativeImageProvider::Image)
{
}

QImage Thumbnailer::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
//    DEBUG() << id << *size << requestedSize;

    QUrl url(id);
    QString thumbnail = QString("%1/.thumbnails/grid/%2.jpeg").arg(QDir::homePath()).arg(QString(QCryptographicHash::hash(url.toString().toUtf8(), QCryptographicHash::Md5).toHex()));
    QImage ret;
    if (QFile::exists(thumbnail)) {
        if (!ret.load(thumbnail)) {
            ret.load(url.path());
        }
    } else {
        ret.load(url.path());
    }
    ret = ret.scaled(160, 160, Qt::KeepAspectRatio, Qt::FastTransformation);
    if (size)
        *size = ret.size();

    if (requestedSize.isValid())
        ret = ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::FastTransformation);
    return ret;
}
