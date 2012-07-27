#include "notification.h"

#include <MNotification>
#include <MGConfItem>

#include <twitter4qml_global.h>

class Notification::Private
{
public:
    Private(Notification *parent);

    bool publish();
    bool remove();

private:
    Notification *q;
public:
    QString eventType;
    QString summary;
    QString body;
    QString image;
    uint count;
    QString identifier;
    MNotification *notification;
};

Notification::Private::Private(Notification *parent)
    : q(parent)
    , count(0)
    , notification(0)
{
}

bool Notification::Private::publish()
{
    if (notification) {
        notification->deleteLater();
        notification = 0;
    }

    if (eventType == QLatin1String("qneptunea.mentions")) {
        MGConfItem conf("/apps/ControlPanel/QNeptunea/Notification/Mentions");
        if (!conf.value().toBool())
            return false;
    }
    if (eventType == QLatin1String("qneptunea.messages")) {
        MGConfItem conf("/apps/ControlPanel/QNeptunea/Notification/DirectMessages");
        if (!conf.value().toBool())
            return false;
    }

    if (eventType == QLatin1String("qneptunea.searches")) {
        MGConfItem conf("/apps/ControlPanel/QNeptunea/Notification/SavedSearches");
        if (!conf.value().toBool())
            return false;
    }

    notification = new MNotification(eventType);
    notification->setSummary(summary);
    notification->setBody(body);
    notification->setImage(image);
    notification->setCount(count);
    notification->setIdentifier(identifier);
    notification->setParent(q);

    MRemoteAction action("com.twitter", "/com/twitter", "com.twitter", identifier, QList<QVariant>());

    notification->setAction(action);
    return notification->publish();
}

bool Notification::Private::remove()
{
    if (notification) {
        notification->remove();
        return true;
    }
    return false;
}

Notification::Notification(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

Notification::~Notification()
{
    delete d;
}

const QString &Notification::eventType() const
{
    return d->eventType;
}

void Notification::setEventType(const QString &eventType)
{
    if (d->eventType == eventType) return;
    d->eventType = eventType;
    emit eventTypeChanged(eventType);
}

const QString &Notification::summary() const
{
    return d->summary;
}

void Notification::setSummary(const QString &summary)
{
    if (d->summary == summary) return;
    d->summary = summary;
    emit summaryChanged(summary);
}

const QString &Notification::body() const
{
    return d->body;
}

void Notification::setBody(const QString &body)
{
    if (d->body == body) return;
    d->body = body;
    emit bodyChanged(body);
}

const QString &Notification::image() const
{
    return d->image;
}

void Notification::setImage(const QString &image)
{
    if (d->image == image) return;
    d->image = image;
    emit imageChanged(image);
}

uint Notification::count() const
{
    return d->count;
}

void Notification::setCount(uint count)
{
    if (d->count == count) return;
    d->count = count;
    emit countChanged(count);
}

const QString &Notification::identifier() const
{
    return d->identifier;
}

void Notification::setIdentifier(const QString &identifier)
{
    if (d->identifier == identifier) return;
    d->identifier = identifier;
    emit identifierChanged(identifier);
}

bool Notification::publish()
{
    return d->publish();
}

bool Notification::remove()
{
    return d->remove();
}

bool Notification::isPublished() const
{
    if (!d->notification) return false;
    return d->notification->isPublished();
}

QList<QObject*> Notification::notifications()
{
    QList<QObject*> ret;
    foreach (MNotification *mnotification, MNotification::notifications()) {
        Notification *notification = new Notification(this);
        notification->d->eventType = mnotification->eventType();
        notification->d->summary = mnotification->summary();
        notification->d->body = mnotification->body();
        notification->d->image = mnotification->image();
        notification->d->count = mnotification->count();
        notification->d->identifier = mnotification->identifier();
        notification->d->notification = mnotification;
        ret.append(notification);
    }
    return ret;
}
