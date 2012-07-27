#include "shareinterface.h"

#include <QtCore/QDebug>
#include <QtDBus/QDBusInterface>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>

class ShareInterface::Private
{
public:
    QString url;
    QString mimeType;
    QString title;
    QString description;
};

ShareInterface::ShareInterface(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
}

ShareInterface::~ShareInterface()
{
    delete d;
}

const QString &ShareInterface::url() const
{
    return d->url;
}

void ShareInterface::setUrl(const QString &url)
{
    if (d->url == url) return;
    d->url = url;
    emit urlChanged(url);
}

const QString &ShareInterface::mimeType() const
{
    return d->mimeType;
}

void ShareInterface::setMimeType(const QString &mimeType)
{
    if (d->mimeType == mimeType) return;
    d->mimeType = mimeType;
    emit mimeTypeChanged(mimeType);
}

const QString &ShareInterface::title() const
{
    return d->title;
}

void ShareInterface::setTitle(const QString &title)
{
    if (d->title == title) return;
    d->title = title;
    emit titleChanged(title);
}

const QString &ShareInterface::description() const
{
    return d->description;
}

void ShareInterface::setDescription(const QString &description)
{
    if (d->description == description) return;
    d->description = description;
    emit descriptionChanged(description);
}

void ShareInterface::share()
{
    MDataUri uri;
    uri.setMimeType(d->mimeType);
    uri.setTextData(d->url);
    if (!d->title.isNull())
        uri.setAttribute("title", d->title);
    if (!d->description.isNull())
        uri.setAttribute("description", d->description);
    if (uri.isValid()) {
        ShareUiInterface shareIf("com.nokia.ShareUi");
        if (shareIf.isValid())
            shareIf.share(QStringList() << uri.toString());
    }
}
