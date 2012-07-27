#include "server.h"
#include <twitter4qml_global.h>

#include <QtCore/QStringList>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusMessage>

Server::Server(QObject *parent)
    : QObject(parent)
    , m_visible(false)
{
    QMetaObject::invokeMethod(this, "listen", Qt::QueuedConnection);
}

void Server::listen()
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    if (connection.registerService("com.twitter")) {
        if (connection.isConnected()) {
            connection.registerObject(QLatin1String("/com/twitter"), this, QDBusConnection::ExportAllContents);
        }
    }
}

void Server::launchWithLink(const QStringList &url)
{
    DEBUG() << url;
    emit openUrl(url);
    activate();
}

void Server::mentions()
{
    emit openUrl(QStringList() << "qneptunea://page/mentions");
    activate();
}

void Server::messages()
{
    emit openUrl(QStringList() << "qneptunea://page/messages");
    activate();
}

void Server::searches()
{
    emit openUrl(QStringList() << "qneptunea://page/searches");
    activate();
}

void Server::activate()
{
    DEBUG();
    emit activated();
}

bool Server::visible() const
{
    return m_visible;
}

void Server::setVisible(bool visible)
{
    if (m_visible == visible) return;
    m_visible = visible;
    emit visibleChanged(visible);
}
