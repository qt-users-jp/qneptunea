#ifndef QNEPTUNEA_H
#define QNEPTUNEA_H

#include <libsyncpluginmgr/ClientPlugin.h>
#include <ClientPlugin.h>
#include <SyncResults.h>

class QNeptunea : public Buteo::ClientPlugin
{
    Q_OBJECT
public:
    QNeptunea(const QString& aPluginName, const Buteo::SyncProfile& aProfile, Buteo::PluginCbInterface *aCbInterface);
    ~QNeptunea();

    bool init();
    bool uninit();
    bool startSync();
    void abortSync(Sync::SyncStatus aStatus = Sync::SYNC_ABORTED);
    Buteo::SyncResults getSyncResults() const;
    bool cleanUp();

public slots:
    void connectivityStateChanged( Sync::ConnectivityType aType, bool aState );

private:
    class Private;
    Private *d;
};

extern "C" QNeptunea* createPlugin(const QString& aPluginName, const Buteo::SyncProfile& aProfile, Buteo::PluginCbInterface *aCbInterface);
extern "C" void destroyPlugin(QNeptunea *aClient);

#endif //QNEPTUNEA_H
