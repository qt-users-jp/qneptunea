#ifndef EVENTFEED_H
#define EVENTFEED_H

#include <QtCore/QObject>
#include <QtCore/QDateTime>
#include <QtCore/QStringList>
#include <QtCore/QUrl>

class EventFeed : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(QStringList imageList READ imageList WRITE setImageList NOTIFY imageListChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)
    Q_PROPERTY(QString footer READ footer WRITE setFooter NOTIFY footerChanged)
    Q_PROPERTY(bool video READ video WRITE setVideo NOTIFY videoChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString sourceName READ sourceName WRITE setSourceName NOTIFY sourceNameChanged)
    Q_PROPERTY(QString sourceDisplayName READ sourceDisplayName WRITE setSourceDisplayName NOTIFY sourceDisplayNameChanged)
public:
    explicit EventFeed(QObject *parent = 0);
    ~EventFeed();

    const QString &icon() const;
    void setIcon(const QString &icon);
    const QString &title() const;
    void setTitle(const QString &title);
    const QString &body() const;
    void setBody(const QString &body);
    const QStringList &imageList() const;
    void setImageList(const QStringList &imageList);
    const QDateTime &timestamp() const;
    void setTimestamp(const QDateTime &timestamp);
    const QString &footer() const;
    void setFooter(const QString &footer);
    bool video() const;
    void setVideo(bool video);
    const QUrl &url() const;
    void setUrl(const QUrl &url);
    const QString &sourceName() const;
    void setSourceName(const QString &sourceName);
    const QString &sourceDisplayName() const;
    void setSourceDisplayName(const QString &sourceDisplayName);

    Q_INVOKABLE qlonglong add();
//    Q_INVOKABLE void remove(qlonglong id);

signals:
    void iconChanged(const QString &icon);
    void titleChanged(const QString &title);
    void bodyChanged(const QString &body);
    void imageListChanged(const QStringList &imageList);
    void timestampChanged(const QDateTime &timestamp);
    void footerChanged(const QString &footer);
    void videoChanged(bool video);
    void urlChanged(const QUrl &url);
    void sourceNameChanged(const QString &sourceName);
    void sourceDisplayNameChanged(const QString &sourceDisplayName);

private:
    Q_DISABLE_COPY(EventFeed)
    class Private;
    Private *d;
};

#endif // EVENTFEED_H
