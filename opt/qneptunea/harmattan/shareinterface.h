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

#ifndef SHAREINTERFACE_H
#define SHAREINTERFACE_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class ShareInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString mimeType READ mimeType WRITE setMimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
public:
    explicit ShareInterface(QObject *parent = 0);
    ~ShareInterface();

    const QString &url() const;
    void setUrl(const QString &url);
    const QString &mimeType() const;
    void setMimeType(const QString &mimeType);
    const QString &title() const;
    void setTitle(const QString &title);
    const QString &description() const;
    void setDescription(const QString &description);

public slots:
    void share();

signals:
    void urlChanged(const QString &url);
    void mimeTypeChanged(const QString &mimeType);
    void titleChanged(const QString &title);
    void descriptionChanged(const QString &description);

private:
    class Private;
    Private *d;
};

#endif // SHAREINTERFACE_H
