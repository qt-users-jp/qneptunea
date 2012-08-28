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

#include "photouploader.h"
#include <QtNetwork/QNetworkReply>
#include <tools/oauthmanager.h>

class PhotoUploader::Private : public QObject
{
    Q_OBJECT
public:
    Private(PhotoUploader *parent);
    void upload(const QUrl &url, const QVariant &parameters);

private slots:
    void finished();
    void error(QNetworkReply::NetworkError err);

private:
    PhotoUploader *q;

public:
    QString verifyCredentialsFormat;
};

PhotoUploader::Private::Private(PhotoUploader *parent)
    : QObject(parent)
    , q(parent)
{
}

void PhotoUploader::Private::upload(const QUrl &url, const QVariant &parameters)
{
    OAuthManager::instance().setAuthorizeBy(OAuthManager::AuthorizeByHeader);
    QMultiMap<QString, QByteArray> params;
    if (parameters.type() == QVariant::Map) {
        QVariantMap map = parameters.toMap();
        foreach (const QString &key, map.keys()) {
            params.insert(key, map.value(key).toByteArray());
        }
    }
    QNetworkReply *reply = OAuthManager::instance().echo("POST", url, params, QUrl("https://api.twitter.com/1/account/verify_credentials." + verifyCredentialsFormat), QUrl("http://api.twitter.com/"), true);
    connect(reply, SIGNAL(finished()), this, SLOT(finished()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
}

void PhotoUploader::Private::finished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
//    foreach (const QByteArray &header, reply->request().rawHeaderList()) {
//        DEBUG() << header << reply->request().rawHeader(header);
//    }
    emit q->done(true, reply->readAll());
}

void PhotoUploader::Private::error(QNetworkReply::NetworkError err)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    emit q->done(false, reply->errorString());
}

PhotoUploader::PhotoUploader(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

const QString &PhotoUploader::verifyCredentialsFormat() const
{
    return d->verifyCredentialsFormat;
}

void PhotoUploader::setVerifyCredentialsFormat(const QString &verifyCredentialsFormat)
{
    if (d->verifyCredentialsFormat == verifyCredentialsFormat) return;
    d->verifyCredentialsFormat = verifyCredentialsFormat;
    emit verifyCredentialsFormatChanged(verifyCredentialsFormat);
}

void PhotoUploader::upload(const QUrl &url, const QVariant &parameters)
{
    d->upload(url, parameters);
}

#include "photouploader.moc"
