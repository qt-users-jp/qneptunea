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
