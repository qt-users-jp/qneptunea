/* Copyright (c) 2012 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "qneptunea.h"
#include <QtCore/QProcess>
#include <QtCore/QDateTime>
#include <QtCore/QTimer>
#include <QtCore/QUrl>
#include <QtCore/QPointer>

#include <PluginCbInterface.h>
#include <LogMacros.h>

#include <MGConfItem>

class QNeptunea::Private : public QObject
{
    Q_OBJECT
public:
    Private(QNeptunea *parent);
    Buteo::SyncResults syncResults;

public slots:
    void start();
    void abort();

private slots:
    void finished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void syncSuccess();
    void syncFailed();
    void updateResults(const Buteo::SyncResults &aResults);

private:
    QNeptunea *q;
    QPointer<QProcess> qneptunea;
    MGConfItem sync;
    MGConfItem mentionsNotification;
    MGConfItem messagesNotification;
    MGConfItem searchesNotification;
};

QNeptunea::Private::Private(QNeptunea *parent)
    : QObject(parent)
    , q(parent)
    , qneptunea(0)
    , sync("/apps/QNeptunea/Sync")
    , mentionsNotification("/apps/ControlPanel/QNeptunea/Notification/Mentions")
    , messagesNotification("/apps/ControlPanel/QNeptunea/Notification/DirectMessages")
    , searchesNotification("/apps/ControlPanel/QNeptunea/Notification/SavedSearches")
{
    connect(&sync, SIGNAL(valueChanged()), this, SLOT(start()));
    connect(&mentionsNotification, SIGNAL(valueChanged()), this, SLOT(start()));
    connect(&messagesNotification, SIGNAL(valueChanged()), this, SLOT(start()));
    connect(&searchesNotification, SIGNAL(valueChanged()), this, SLOT(start()));
}

void QNeptunea::Private::start()
{
    qDebug() << Q_FUNC_INFO << sync.value();

    if (sync.value(true).toBool() &&
            ( mentionsNotification.value(true).toBool()
            || messagesNotification.value(true).toBool()
            || searchesNotification.value(true).toBool() )
            ) {
        if (qneptunea) return;
        qneptunea = new QProcess(this);
        connect(qneptunea, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(finished(int, QProcess::ExitStatus)));
        qneptunea->start("/opt/qneptunea/bin/qneptunea", QStringList() << "cron");
    } else {
        syncSuccess();
    }
}

void QNeptunea::Private::abort()
{
    if (!qneptunea) return;
    qneptunea->terminate();
}

void QNeptunea::Private::finished(int exitCode, QProcess::ExitStatus exitStatus)
{
    switch (exitStatus) {
    case QProcess::NormalExit:
        if (exitCode == 0) {
            syncSuccess();
        } else {
            syncFailed();
        }
        break;
    case QProcess::CrashExit:
        syncFailed();
        break;
    }
    if (qneptunea) {
        qneptunea->deleteLater();
        qneptunea = 0;
    }
}

void QNeptunea::Private::syncSuccess()
{
    FUNCTION_CALL_TRACE;
    updateResults(Buteo::SyncResults(QDateTime::currentDateTime(), Buteo::SyncResults::SYNC_RESULT_SUCCESS, Buteo::SyncResults::NO_ERROR));
    //Notify Sync FW of result - Now sync fw will call uninit and then will unload plugin
    emit q->success(q->getProfileName(), "Success!!");
}

void QNeptunea::Private::syncFailed()
{
    FUNCTION_CALL_TRACE;
    //Notify Sync FW of result - Now sync fw will call uninit and then will unload plugin
    updateResults(Buteo::SyncResults(QDateTime::currentDateTime(),
                                     Buteo::SyncResults::SYNC_RESULT_FAILED, Buteo::SyncResults::ABORTED));
    emit q->error(q->getProfileName(), "Error!!", Buteo::SyncResults::SYNC_RESULT_FAILED);
}

void QNeptunea::Private::updateResults(const Buteo::SyncResults &aResults)
{
    FUNCTION_CALL_TRACE;
    syncResults = aResults;
    syncResults.setScheduled(true);
}


extern "C" QNeptunea* createPlugin(const QString& aPluginName, const Buteo::SyncProfile& aProfile, Buteo::PluginCbInterface *aCbInterface)
{
    return new QNeptunea(aPluginName, aProfile, aCbInterface);
}

extern "C" void destroyPlugin(QNeptunea*aClient)
{
    delete aClient;
}

QNeptunea::QNeptunea(const QString& aPluginName, const Buteo::SyncProfile& aProfile, Buteo::PluginCbInterface *aCbInterface)
    : ClientPlugin(aPluginName, aProfile, aCbInterface)
{
    FUNCTION_CALL_TRACE;
}

QNeptunea::~QNeptunea()
{
    FUNCTION_CALL_TRACE;
}

bool QNeptunea::init()
{
    FUNCTION_CALL_TRACE;
    d = new Private(this);
    return true;
}

bool QNeptunea::uninit()
{
    FUNCTION_CALL_TRACE;
    delete d;
    return true;
}

bool QNeptunea::startSync()
{
    FUNCTION_CALL_TRACE;

    QTimer::singleShot(1000, d, SLOT(start()));

    return true;
}

void QNeptunea::abortSync(Sync::SyncStatus aStatus)
{
    FUNCTION_CALL_TRACE;
    Q_UNUSED(aStatus);
    d->abort();
}

bool QNeptunea::cleanUp()
{
    FUNCTION_CALL_TRACE;
    return true;
}

Buteo::SyncResults QNeptunea::getSyncResults() const
{
    FUNCTION_CALL_TRACE;
    return d->syncResults;
}

void QNeptunea::connectivityStateChanged(Sync::ConnectivityType aType,
                                             bool aState)
{
    FUNCTION_CALL_TRACE;
    // This function notifies of the plugin of any connectivity related state changes
    LOG_DEBUG("Received connectivity change event:" << aType << " changed to " << aState);
    if ((aType == Sync::CONNECTIVITY_INTERNET) && (aState == false)) {
        // Network disconnect!!
    }
}

#include "qneptunea.moc"
