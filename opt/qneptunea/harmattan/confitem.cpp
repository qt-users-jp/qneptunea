#include "confitem.h"
#include <MGConfItem>

ConfItem::ConfItem(QObject *parent)
    : QObject(parent)
    , conf(0)
{
}

QString ConfItem::key() const
{
    if (conf) {
        return conf->key();
    }
    return QString();
}

QVariant ConfItem::value() const
{
    if (conf) {
        return conf->value();
    }
    return QVariant();
}

void ConfItem::setKey(const QString &key)
{
    if (this->key() == key) return;
    if (conf) {
        delete conf;
    }
    conf = new MGConfItem(key, this);
    connect(conf, SIGNAL(valueChanged()), this, SIGNAL(valueChanged()));
    emit keyChanged(key);
}

void ConfItem::setValue(const QVariant &value)
{
    if (this->value() == value) return;
    if (!conf) {
        conf = new MGConfItem(key(), this);
        connect(conf, SIGNAL(valueChanged()), this, SIGNAL(valueChanged()));
    }
    conf->set(value);
}
