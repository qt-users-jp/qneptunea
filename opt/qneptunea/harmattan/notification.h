#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QObject>

class Notification : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString eventType READ eventType WRITE setEventType NOTIFY eventTypeChanged)
    Q_PROPERTY(QString summary READ summary WRITE setSummary NOTIFY summaryChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(QString image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(uint count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QString identifier READ identifier WRITE setIdentifier NOTIFY identifierChanged)
public:
    explicit Notification(QObject *parent = 0);
    ~Notification();

    const QString &eventType() const;
    const QString &summary() const;
    const QString &body() const;
    const QString &image() const;
    uint count() const;
    const QString &identifier() const;

    Q_INVOKABLE bool isPublished() const;
    Q_INVOKABLE QList<QObject*> notifications();

public slots:
    void setEventType(const QString &eventType);
    void setSummary(const QString &summary);
    void setBody(const QString &body);
    void setImage(const QString &image);
    void setCount(uint count);
    void setIdentifier(const QString &identifier);

//    void setAction(const MRemoteAction &action);

    bool publish();
    bool remove();

signals:
    void eventTypeChanged(const QString &eventType);
    void summaryChanged(const QString &summary);
    void bodyChanged(const QString &body);
    void imageChanged(const QString &image);
    void countChanged(uint count);
    void identifierChanged(const QString &identifier);

//    void action(const MRemoteAction &action);

private:
    class Private;
    Private *d;
};

#endif // NOTIFICATION_H
