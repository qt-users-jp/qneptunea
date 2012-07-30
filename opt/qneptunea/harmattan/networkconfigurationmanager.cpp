#include "networkconfigurationmanager.h"

#include <twitter4qml_global.h>

class NetworkConfigurationManager::Private : public QObject
{
    Q_OBJECT
public:
    Private(NetworkConfigurationManager *parent);

    bool online;

private slots:
    void debug();

private:
    NetworkConfigurationManager *q;
    QNetworkConfigurationManager manager;
};

NetworkConfigurationManager::Private::Private(NetworkConfigurationManager *parent)
    : QObject(parent)
    , online(false)
    , q(parent)
{
    connect(&manager, SIGNAL(configurationChanged(QNetworkConfiguration)), this, SLOT(debug()));
    connect(&manager, SIGNAL(updateCompleted()), this, SLOT(debug()));
    connect(&manager, SIGNAL(onlineStateChanged(bool)), this, SLOT(debug()));
    manager.updateConfigurations();
}

void NetworkConfigurationManager::Private::debug()
{
    bool o = manager.isOnline();
    if (online == o) return;
    online = o;
    emit q->onlineStateChanged(online);
}

NetworkConfigurationManager::NetworkConfigurationManager(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

bool NetworkConfigurationManager::isOnline() const
{
    return d->online;
}

#include "networkconfigurationmanager.moc"
