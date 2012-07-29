#include "profileimage.h"
#include "networkconfigurationmanager.h"

#include <QtCore/QBuffer>
#include <QtCore/QCryptographicHash>
#include <QtCore/QDateTime>
#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QFileInfo>
#include <QtCore/QProcess>
#include <QtCore/QTimer>
#include <QtCore/QtConcurrentRun>
#include <QtCore/QFutureWatcher>
#include <QtGui/QBitmap>
#include <QtGui/QImageReader>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>

#define DEBUG() qDebug() << __PRETTY_FUNCTION__ << __LINE__

void createAvatar(QIODevice *ioDevice, QString cache);

class ProfileImage::Private : public QObject
{
    Q_OBJECT
public:
    Private(ProfileImage *parent);
    ~Private();

    QUrl source;
    QUrl id;
    QUrl cache;

private slots:
    void changed();
    void onlineStateChanged(bool online);
    void check();
    void retrieve();
    void setCache(const QUrl &cache);
    void finished();
    void done();

private:
    inline QString sourceHash() { return QString(QCryptographicHash::hash(source.toString().toUtf8(), QCryptographicHash::Md5).toHex()); }
    inline QString idHash() { return QString(QCryptographicHash::hash(id.toString().toUtf8(), QCryptographicHash::Md5).toHex()); }

private:
    ProfileImage *q;
    QTimer timer;
    QNetworkReply *reply;
    QFutureWatcher<void> watcher;

public:
    static QDir cacheDir;
    static QMap<int, QImage> masks;
    static QMap<QString, QString> avatars;
    static QMap<QString, int> avatarsCounter;
    static QNetworkAccessManager *networkAccessManager;
    static NetworkConfigurationManager *networkConfigurationManager;
};

QDir ProfileImage::Private::cacheDir;
QMap<int, QImage> ProfileImage::Private::masks;
QMap<QString, QString> ProfileImage::Private::avatars;
QMap<QString, int> ProfileImage::Private::avatarsCounter;
QNetworkAccessManager *ProfileImage::Private::networkAccessManager = 0;
NetworkConfigurationManager *ProfileImage::Private::networkConfigurationManager = 0;

void createAvatar(QIODevice *ioDevice, QString cache)
{
    QBuffer buffer;
    buffer.setData(ioDevice->readAll());
    ioDevice->deleteLater();
    QImage sourceImage;
    QImageReader reader(&buffer);
    if (!reader.read(&sourceImage)) {
        return;
    }

    QImage maskImage;
    int width = sourceImage.width();
    if (width == sourceImage.height() && ProfileImage::Private::masks.contains(width)) {
        maskImage = ProfileImage::Private::masks[width];
    } else {
        maskImage = ProfileImage::Private::masks[73].scaled(sourceImage.size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    }

    QImage targetImage(sourceImage.size(), QImage::Format_ARGB32);
    switch (sourceImage.format()) {
    case QImage::Format_RGB32:
    case QImage::Format_ARGB32:
        for (int y = 0; y < sourceImage.height(); y++) {
            QRgb *target = (QRgb *)targetImage.scanLine(y);
            QRgb *source = (QRgb *)sourceImage.scanLine(y);
            QRgb *mask = (QRgb *)maskImage.scanLine(y);
            for (int x = 0; x < sourceImage.width(); x++) {
                *target = (*source & 0x00ffffff) | (((*mask & 0xff000000) >> 24) * ((*source & 0xff000000) >> 24) / 0xff) << 24;
                target++;
                source++;
                mask++;
            }
        }
        break;
    case QImage::Format_Indexed8: {
        QVector<QRgb> colorTable = sourceImage.colorTable();
        for (int y = 0; y < sourceImage.height(); y++) {
            QRgb *target = (QRgb *)targetImage.scanLine(y);
            uchar *index = sourceImage.scanLine(y);
            QRgb *mask = (QRgb *)maskImage.scanLine(y);
            for (int x = 0; x < sourceImage.width(); x++) {
                QRgb source = colorTable.at(*index);
                *target = (source & 0x00ffffff) | (((*mask & 0xff000000) >> 24) * ((source & 0xff000000) >> 24) / 0xff) << 24;
                target++;
                index++;
                mask++;
            }
        }
        break; }
    default:
        for (int y = 0; y < sourceImage.height(); y++) {
            QRgb *target = (QRgb *)targetImage.scanLine(y);
            QRgb *mask = (QRgb *)maskImage.scanLine(y);
            for (int x = 0; x < sourceImage.width(); x++) {
                QRgb source = sourceImage.pixel(x, y);
                *target = (source & 0x00ffffff) | (((*mask & 0xff000000) >> 24) * ((source & 0xff000000) >> 24) / 0xff) << 24;
                target++;
                mask++;
            }
        }
        break;
    }
    targetImage.save(cache);
}

ProfileImage::Private::Private(ProfileImage *parent)
    : QObject(parent)
    , q(parent)
    , reply(0)
{
    timer.setSingleShot(true);
    timer.setInterval(50);
    connect(&timer, SIGNAL(timeout()), this, SLOT(check()));
    connect(q, SIGNAL(sourceChanged(QUrl)), this, SLOT(changed()), Qt::QueuedConnection);
    connect(q, SIGNAL(idChanged(QUrl)), this, SLOT(changed()), Qt::QueuedConnection);
    connect(&watcher, SIGNAL(finished()), this, SLOT(done()));
}

ProfileImage::Private::~Private()
{
}

void ProfileImage::Private::changed()
{
    if (timer.isActive()) return;
    timer.start();
}

void ProfileImage::Private::onlineStateChanged(bool online)
{
    if (online) retrieve();
}

void ProfileImage::Private::check()
{
    if (reply) {
        reply->abort();
        reply->deleteLater();
        reply = 0;
    }
    setCache(QUrl());
    if (!source.isValid()) {
        return;
    }
    if (!source.scheme().startsWith("http")) {
        setCache(source);
        return;
    }
    if (id.toString().isEmpty() && avatars.contains(sourceHash())) {
        q->setId(avatars.value(sourceHash()));
        return;
    }
    QString thumbnail = QString("%1-%2.png").arg(sourceHash()).arg(idHash());

    if (avatars.contains(sourceHash()) && avatars.value(sourceHash()) == idHash()) {
        setCache(cacheDir.absoluteFilePath(thumbnail));
    } else {
        if (networkConfigurationManager->isOnline()) {
            QTimer::singleShot(10, this, SLOT(retrieve()));
        } else {
            connect(networkConfigurationManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(onlineStateChanged(bool)));
        }
    }
}

void ProfileImage::Private::retrieve()
{
    QNetworkRequest request(source);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setRawHeader("User-Agent", "QNeptunea for Nokia N9");
    reply = networkAccessManager->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(finished()));
}

void ProfileImage::Private::finished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (this->reply != reply) {
        reply->deleteLater();
        return;
    }

    QVariant redirect = reply->attribute(QNetworkRequest::RedirectionTargetAttribute);

    if (redirect.type() == QVariant::Url) {
        QNetworkRequest request(redirect.toUrl());
        request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
        request.setRawHeader("User-Agent", "QNeptunea for Nokia N9");
        this->reply = networkAccessManager->get(request);
        connect(this->reply, SIGNAL(finished()), this, SLOT(finished()));
        reply->deleteLater();
        return;
    }

    this->reply = 0;

    QString thumbnail = QString("%1-%2.png").arg(sourceHash()).arg(idHash());
    watcher.setFuture(QtConcurrent::run(createAvatar, reply, cacheDir.absoluteFilePath(thumbnail)));
}

void ProfileImage::Private::done()
{
    QString thumbnail = QString("%1-%2.png").arg(sourceHash()).arg(idHash());
    setCache(cacheDir.absoluteFilePath(thumbnail));
}

void ProfileImage::Private::setCache(const QUrl &cache)
{
    if (this->cache == cache) return;
    this->cache = cache;
    if (cache.isValid()) {
        QString key = sourceHash();
        QString value = idHash();
        if (cache != source) {
            if (!avatars.contains(sourceHash())) {
                // insert
                {
                    QSqlQuery query("INSERT INTO Cache (key, value) VALUES(?, ?);");
                    query.addBindValue(key);
                    query.addBindValue(value);
                    if (!query.exec()) {
                        DEBUG() << query.lastError();
                        DEBUG() << key << value << query.boundValues();
                    }
                }
            } else if (avatars.value(key) != value) {
                DEBUG() << source << id << avatars.value(key) << value;
                // remove previous cache
                {
                    QSqlQuery query("SELECT value FROM Cache WHERE key=?;");
                    query.addBindValue(key);
                    if (query.first()) {
                        cacheDir.remove(query.value(0).toString());
                    } else {
                        DEBUG() << query.lastError();
                    }
                }

                // update
                {
                    QSqlQuery query("UPDATE Cache SET value=?, lastModified = CURRENT_TIMESTAMP WHERE key=?;");
                    query.addBindValue(value);
                    query.addBindValue(key);
                    if (!query.exec()) {
                        DEBUG() << query.lastError();
                    }
                }
            } else {
                // update lastModified
                QSqlQuery query("UPDATE Cache SET lastModified = CURRENT_TIMESTAMP WHERE key=?;");
                query.addBindValue(key);
                if (!query.exec()) {
                    DEBUG() << query.lastError();
                }
            }
        }
        avatars[sourceHash()] = idHash();
    }
    QMetaObject::invokeMethod(q, "cacheChanged", Qt::QueuedConnection, Q_ARG(QUrl, cache));
}

void ProfileImage::setup(QNetworkAccessManager *networkAccessManager)
{
    ProfileImage::Private::networkAccessManager = networkAccessManager;
    ProfileImage::Private::networkConfigurationManager = new NetworkConfigurationManager;
    QDir cacheDir = QDir::homePath();

    QString dotCache(".cache");
    if (!cacheDir.exists(dotCache)) cacheDir.mkdir(dotCache);
    cacheDir.cd(dotCache);

    QString qneptunea("qneptunea");
    if (!cacheDir.exists(qneptunea)) cacheDir.mkdir(qneptunea);
    cacheDir.cd(qneptunea);

    ProfileImage::Private::cacheDir = cacheDir;

    ProfileImage::Private::masks.insert(48, QImage(":/avatar-mask48.png"));
    ProfileImage::Private::masks.insert(73, QImage(":/avatar-mask73.png"));

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(cacheDir.absoluteFilePath("cache.db"));
    if (!db.open()) {
        DEBUG() << db.lastError();
        return;
    }
    db.transaction();
    if (db.tables().isEmpty()) {
        cacheDir.setNameFilters(QStringList() << "*.png");
        cacheDir.setFilter(QDir::Files | QDir::NoDotAndDotDot);
        cacheDir.setSorting(QDir::Time);

        foreach (const QFileInfo &finfo, cacheDir.entryInfoList()) {
            cacheDir.remove(finfo.fileName());
        }
    }
    // create table
    {
        QSqlQuery query("CREATE TABLE IF NOT EXISTS Cache ("
                        "key TEXT PRIMARY KEY"
                        ", value TEXT UNIQUE NOT NULL"
                        ", lastModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
                        ");"
                        );
        if (!query.exec()) {
            DEBUG() << query.lastError();
            DEBUG() << query.lastQuery();
            return;
        }
    }

    {
        QSqlQuery query("SELECT key, value FROM Cache;");
        QSqlRecord record = query.record();
        int key = record.indexOf("key");
        int value = record.indexOf("value");
        while (query.next()) {
//            DEBUG() << query.value(key).toString() << query.value(value).toString();
            ProfileImage::Private::avatars.insert(query.value(key).toString(), query.value(value).toString());
        }
    }
}

void ProfileImage::cleanup()
{
    QDir cacheDir = ProfileImage::Private::cacheDir;

    QSqlQuery query("SELECT key, value FROM Cache ORDER BY lastModified LIMIT 100000 OFFSET 1000;");
    QSqlRecord record = query.record();
    int key = record.indexOf("key");
    int value = record.indexOf("value");
    while (query.next()) {
        DEBUG() << query.value(key).toString() << query.value(value).toString();
        cacheDir.remove(QString("%1-%2.png").arg(query.value(key).toString()).arg(query.value(value).toString()));

        QSqlQuery remove("DELETE FROM Cache WHERE key=?;");
        remove.addBindValue(query.value(key).toString());
        if (!remove.exec()) {
            DEBUG() << remove.lastError();
            DEBUG() << remove.lastQuery() << query.value(key).toInt();
        }
    }
    QSqlDatabase db = QSqlDatabase::database();
    db.commit();
    delete ProfileImage::Private::networkConfigurationManager;
}

ProfileImage::ProfileImage(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

const QUrl &ProfileImage::source() const
{
    return d->source;
}

void ProfileImage::setSource(const QUrl &source)
{
    if (d->source == source) return;
    d->source = source;
    emit sourceChanged(source);
}

const QUrl &ProfileImage::id() const
{
    return d->id;
}

void ProfileImage::setId(const QUrl &id)
{
    if (d->id == id) return;
    d->id = id;
    emit idChanged(id);
}

const QUrl &ProfileImage::cache() const
{
    return d->cache;
}

#include "profileimage.moc"
