/* Copyright (c) 2012-2013 QNeptunea Project.
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

#include "pluginloader.h"

#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QCoreApplication>

#define DEBUG() qDebug() << __PRETTY_FUNCTION__ << __LINE__

class PluginLoader::Private : public QObject
{
    Q_OBJECT
public:
    Private(PluginLoader *parent);

    void reload();

    QString type;
    QStringList plugins;
    QList<QObject *> childObjects;

    static void appendFunction(QDeclarativeListProperty<QObject> *list, QObject *object);
    static int countFunction(QDeclarativeListProperty<QObject> *list);
    static QObject *atFunction(QDeclarativeListProperty<QObject> *list, int index);

private slots:
    void typeChanged(const QString &type);
    void setPlugins(const QStringList &plugins);

private:
    PluginLoader *q;
};

PluginLoader::Private::Private(PluginLoader *parent)
    : QObject(parent)
    , q(parent)
{
    connect(q, SIGNAL(typeChanged(QString)), this, SLOT(typeChanged(QString)));
    typeChanged(type);
}

void PluginLoader::Private::typeChanged(const QString &type)
{
    if (type.contains(".") || type.contains("/")) {
        q->setType("");
        return;
    }
    if (type.isEmpty()) {
        setPlugins(QStringList());
    } else {
        reload();
    }
}

void PluginLoader::Private::reload()
{
    QStringList plugins;
    QDir dir(QCoreApplication::applicationDirPath());

    dir.cdUp();
    if (!dir.cd(QLatin1String("plugins"))) {
        goto ret;
    }
    if (!dir.cd(type)) {
        goto ret;
    }

    foreach (const QString &plugin, dir.entryList(QStringList() << "*.qml", QDir::Files | QDir::NoDotAndDotDot, QDir::Name))
        plugins.append(dir.absoluteFilePath(plugin));

    dir = QDir::home();
    if (dir.cd(QLatin1String("qneptunea-plugins"))) {
        if (dir.cd(type)) {
            foreach (const QString &plugin, dir.entryList(QStringList() << "*.qml", QDir::Files | QDir::NoDotAndDotDot, QDir::Name))
                plugins.append(dir.absoluteFilePath(plugin));
        }
    }
ret:
//    DEBUG() << plugins;
    setPlugins(plugins);
}

void PluginLoader::Private::setPlugins(const QStringList &plugins)
{
    if (this->plugins == plugins) return;
    this->plugins = plugins;
    emit q->pluginsChanged(plugins);
}

void PluginLoader::Private::appendFunction(QDeclarativeListProperty<QObject> *list, QObject *object)
{
    PluginLoader::Private *d = qobject_cast<PluginLoader::Private *>(list->object);
    if (d) {
        d->childObjects.append(object);
    }
}

int PluginLoader::Private::countFunction(QDeclarativeListProperty<QObject> *list)
{
    int ret = -1;
    PluginLoader::Private *d = qobject_cast<PluginLoader::Private *>(list->object);
    if (d) {
        ret = d->childObjects.count();
    }
    return ret;
}

QObject *PluginLoader::Private::atFunction(QDeclarativeListProperty<QObject> *list, int index)
{
    QObject *ret = 0;
    PluginLoader::Private *d = qobject_cast<PluginLoader::Private *>(list->object);
    if (d) {
        ret = d->childObjects.at(index);
    }
    return ret;
}


PluginLoader::PluginLoader(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

void PluginLoader::reload()
{
    d->reload();
}

const QString &PluginLoader::type() const
{
    return d->type;
}

void PluginLoader::setType(const QString &type)
{
    if (d->type == type) return;
    d->type = type;
    emit typeChanged(type);
}

const QStringList &PluginLoader::plugins() const
{
    return d->plugins;
}

QDeclarativeListProperty<QObject> PluginLoader::childObjects()
{
    return QDeclarativeListProperty<QObject>(d, 0, &Private::appendFunction, &Private::countFunction, &Private::atFunction);
}

#include "pluginloader.moc"
