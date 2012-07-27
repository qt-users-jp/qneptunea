#include "thumbnailer.h"

#include <QDebug>
#include <QtCore/QUrl>
#include <QtCore/QDir>
#include <QtCore/QFileInfo>
#include <QtCore/QCryptographicHash>

#define DEBUG() qDebug() << __PRETTY_FUNCTION__ << __LINE__

Thumbnailer::Thumbnailer()
    : QDeclarativeImageProvider(QDeclarativeImageProvider::Image)
{
}

QImage Thumbnailer::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
//    DEBUG() << id << *size << requestedSize;

    QUrl url(id);
    QString thumbnail = QString("%1/.thumbnails/grid/%2.jpeg").arg(QDir::homePath()).arg(QString(QCryptographicHash::hash(url.toString().toUtf8(), QCryptographicHash::Md5).toHex()));
    QImage ret;
    if (QFile::exists(thumbnail)) {
        if (!ret.load(thumbnail)) {
            ret.load(url.path());
        }
    } else {
        ret.load(url.path());
    }
    ret = ret.scaled(160, 160, Qt::KeepAspectRatio, Qt::FastTransformation);
    if (size)
        *size = ret.size();

    if (requestedSize.isValid())
        ret = ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::FastTransformation);
    return ret;
}
