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
