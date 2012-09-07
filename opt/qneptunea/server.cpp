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

#include "server.h"
#include <twitter4qml_global.h>

#include <QtCore/QCoreApplication>
#include <QtCore/QDir>
#include <QtCore/QTranslator>
#include <QtCore/QSettings>
#include <QtCore/QStringList>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusMessage>

class Server::Private
{
public:
    Private();
    bool visible;
    QVariantList translations;
    QVariantMap translation;
};

Server::Private::Private()
    : visible(false)
{
    QSettings settings;
    settings.beginGroup(QLatin1String("Application"));
    QString lang = settings.value(QLatin1String("Language"), QLatin1String("en")).toString();

    QDir dir("/opt/qneptunea/share/translations/");
    foreach (const QString &qm, dir.entryList(QStringList() << "qneptunea_*.qm", QDir::Files, QDir::Name)) {
        QTranslator *translator = new QTranslator(qApp);
        translator->load(dir.absoluteFilePath(qm));

        QVariantMap t;
        QString code = translator->translate("Translation", "en (Please translate this \"en\" to *your* langage code like \"ja\" or \"pt_PT\".)").section(QLatin1String(" ("), 0, 0);
        if (code.isEmpty())
            code = translator->translate("Translation", "en");
        QString name = translator->translate("Translation", "English (Please translate this \"English\" to *your* langage name like \"Japanese\" or \"Portuguese (Portugal)\".)").section(QLatin1String(" ("), 0, 0);
        if (name.isEmpty())
            name = translator->translate("Translation", "English");
        t.insert(QLatin1String("code"), code);
        t.insert(QLatin1String("name"), name);
        if (code == lang) {
            qApp->installTranslator(translator);
            translation = t;
        }
//        DEBUG() << t;
        bool inserted = false;
        for (int i = 0; i < translations.count(); i++) {
            if (translations.at(i).toMap().value(QLatin1String("name")).toString() > name) {
                translations.insert(i, t);
                inserted = true;
                break;
            }
        }
        if (!inserted)
            translations.append(t);
    }

    if (translation.isEmpty())
        translation = translations.first().toMap();
}

Server::Server(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
    QMetaObject::invokeMethod(this, "listen", Qt::QueuedConnection);
}

Server::~Server()
{
    delete d;
}

bool Server::isDeveloper(const QString &screen_name) const
{
    QString translators = qApp->translate("AboutPage", "translator_twitter_id(s) (Please translate this \"translator_twitter_id(s)\" to *your* twitter id(s) like \"task_jp\" or \"task_jp, LogonAniket\".)");
    if (translators == QLatin1String("translator_twitter_id(s) (Please translate this \"translator_twitter_id(s)\" to *your* twitter id(s) like \"task_jp\" or \"task_jp, LogonAniket\".)"))
        translators.clear();
    DEBUG() << translators;
    if (screen_name == QLatin1String("task_jp")) return true;
    if (screen_name == QLatin1String("kenya888")) return true;
    if (screen_name == QLatin1String("LogonAniket")) return true;
    if (translators.split(",").contains(screen_name)) return true;
    return false;
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
    return d->visible;
}

void Server::setVisible(bool visible)
{
    if (d->visible == visible) return;
    d->visible = visible;
    emit visibleChanged(visible);
}

const QVariantList &Server::translations() const
{
    return d->translations;
}

const QVariantMap &Server::translation() const
{
    return d->translation;
}

void Server::setTranslation(const QVariantMap &translation)
{
    if (d->translation == translation) return;
    d->translation = translation;
    QSettings settings;
    settings.beginGroup(QLatin1String("Application"));
    settings.setValue(QLatin1String("Language"), translation.value("code").toString());
    emit translationChanged(translation);
}
