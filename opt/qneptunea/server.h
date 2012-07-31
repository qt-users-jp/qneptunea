#ifndef SERVER_H
#define SERVER_H

#include <QtCore/QObject>
#include <QtCore/QVariantList>

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.twitter")
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(QVariantList translations READ translations NOTIFY translationsChanged)
    Q_PROPERTY(QVariantMap translation READ translation WRITE setTranslation NOTIFY translationChanged)
public:
    explicit Server(QObject *parent = 0);
    ~Server();
    
    bool visible() const;
    const QVariantList &translations() const;
    const QVariantMap &translation() const;

public slots:
    void listen();
    void launchWithLink(const QStringList &url);
    void mentions();
    void messages();
    void searches();
    void activate();
    void setVisible(bool visible);
    void setTranslation(const QVariantMap &translation);

signals:
    void openUrl(const QStringList &url);
    void activated();
    void visibleChanged(bool visible);
    void translationsChanged(const QVariantList &translation);
    void translationChanged(const QVariant &translation);

private:
    class Private;
    Private *d;
};

#endif // SERVER_H
