#ifndef NETWORKCONFIGURATIONMANAGER_H
#define NETWORKCONFIGURATIONMANAGER_H

#include <QNetworkConfigurationManager>

class NetworkConfigurationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool online READ isOnline NOTIFY onlineStateChanged)
public:
    explicit NetworkConfigurationManager(QObject *parent = 0);

    bool isOnline() const;

signals:
    void onlineStateChanged(bool online);

private:
    class Private;
    Private *d;
};

#endif // NETWORKCONFIGURATIONMANAGER_H
