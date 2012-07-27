#ifndef PHOTOUPLOADER_H
#define PHOTOUPLOADER_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class PhotoUploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString verifyCredentialsFormat READ verifyCredentialsFormat WRITE setVerifyCredentialsFormat NOTIFY verifyCredentialsFormatChanged)
public:
    PhotoUploader(QObject *parent = 0);

    const QString &verifyCredentialsFormat() const;

public slots:
    void setVerifyCredentialsFormat(const QString &verifyCredentialsFormat);
    void upload(const QUrl &url, const QVariant &parameters);

signals:
    void verifyCredentialsFormatChanged(const QString &verifyCredentialsFormat);
    void done(bool ok, const QVariant &result);

private:
    class Private;
    Private *d;
};


#endif // PHOTOUPLOADER_H
