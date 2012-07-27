#ifndef PLUGINLOADER_H
#define PLUGINLOADER_H

#include <QtCore/QObject>
#include <QtCore/QStringList>
#include <QtDeclarative/QDeclarativeListProperty>

class PluginLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QStringList plugins READ plugins NOTIFY pluginsChanged)
    Q_PROPERTY(QDeclarativeListProperty<QObject> children READ childObjects)
    Q_CLASSINFO("DefaultProperty", "children")
public:
    explicit PluginLoader(QObject *parent = 0);

    const QString &type() const;
    const QStringList &plugins() const;
    QDeclarativeListProperty<QObject> childObjects();

public slots:
    void setType(const QString &type);
    void reload();
    
signals:
    void typeChanged(const QString &type);
    void pluginsChanged(const QStringList &plugins);

private:
    class Private;
    Private *d;
};

#endif // PLUGINLOADER_H
