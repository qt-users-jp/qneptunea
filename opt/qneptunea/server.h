#ifndef SERVER_H
#define SERVER_H

#include <QtCore/QObject>

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.twitter")
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
public:
    explicit Server(QObject *parent = 0);
    
    Q_INVOKABLE bool visible() const;
public slots:
    void listen();
    void launchWithLink(const QStringList &url);
    void mentions();
    void messages();
    void searches();
    void activate();
    void setVisible(bool visible);

signals:
    void openUrl(const QStringList &url);
    void activated();
    void visibleChanged(bool visible);

private:
    bool m_visible;
};

#endif // SERVER_H
