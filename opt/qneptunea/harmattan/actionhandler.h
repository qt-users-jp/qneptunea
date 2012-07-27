#ifndef ACTIONHANDLER_H
#define ACTIONHANDLER_H

#include <QObject>

class ActionHandler : public QObject
{
    Q_OBJECT
public:
    explicit ActionHandler(QObject *parent = 0);

public slots:
    void openUrlExternally(const QString &url);
};

#endif // ACTIONHANDLER_H
