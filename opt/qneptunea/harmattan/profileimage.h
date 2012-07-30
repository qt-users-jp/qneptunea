#ifndef PROFILEIMAGE_H
#define PROFILEIMAGE_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class QNetworkAccessManager;
class NetworkConfigurationManager;

class ProfileImage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QUrl _id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QUrl cache READ cache NOTIFY cacheChanged)
public:
    static void setup(QNetworkAccessManager *networkAccessManager, NetworkConfigurationManager *networkConfigurationManager);
    static void cleanup();
    explicit ProfileImage(QObject *parent = 0);

    const QUrl &source() const;
    const QUrl &id() const;
    const QUrl &cache() const;

public slots:
    void setSource(const QUrl &source);
    void setId(const QUrl &id);

signals:
    void sourceChanged(const QUrl &source);
    void idChanged(const QUrl &id);
    void cacheChanged(const QUrl &cache);

public:
    class Private;
private:
    Private *d;
};

#endif // PROFILEIMAGE_H
