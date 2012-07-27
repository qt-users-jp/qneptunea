#ifndef THUMBNAILER_H
#define THUMBNAILER_H

#include <QDeclarativeImageProvider>

class Thumbnailer : public QDeclarativeImageProvider
{
public:
    Thumbnailer();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // THUMBNAILER_H
