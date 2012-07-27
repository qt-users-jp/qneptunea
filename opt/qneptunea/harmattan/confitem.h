#ifndef CONFITEM_H
#define CONFITEM_H

#include <QtCore/QObject>
#include <QtCore/QVariant>
class MGConfItem;

class ConfItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)
public:
    explicit ConfItem(QObject *parent = 0);
    
    QString key() const;
    QVariant value() const;

public slots:
    void setKey(const QString &key);
    void setValue(const QVariant &value);

signals:
    void keyChanged(const QString &key);
    void valueChanged();

private:
    MGConfItem* conf;
};

#endif // CONFITEM_H
