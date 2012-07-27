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
