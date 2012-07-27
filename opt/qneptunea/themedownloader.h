#ifndef THEMEDOWNLOADER_H
#define THEMEDOWNLOADER_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class QNetworkAccessManager;

class ThemeDownloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString localPath READ localPath WRITE setLocalPath NOTIFY localPathChanged)
    Q_PROPERTY(QString remoteUrl READ remoteUrl WRITE setRemoteUrl NOTIFY remoteUrlChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QUrl themeFile READ themeFile NOTIFY themeFileChanged)
    Q_PROPERTY(bool cancelling READ cancelling NOTIFY cancellingChanged)
public:
    static QNetworkAccessManager *networkAccessManager;
    explicit ThemeDownloader(QObject *parent = 0);

    const QString &localPath() const;
    const QString &remoteUrl() const;
    bool exists() const;
    bool running() const;
    int progress() const;
    const QUrl &themeFile() const;
    bool cancelling() const;

public slots:
    void start();
    void cancel();
    void cleanup();

    void setLocalPath(const QString &localPath);
    void setRemoteUrl(const QString &remoteUrl);

signals:
    void localPathChanged(const QString &localPath);
    void remoteUrlChanged(const QString &remoteUrl);
    void existsChanged(bool exists);
    void runningChanged(bool running);
    void progressChanged(int progress);
    void themeFileChanged(const QUrl &themeFile);
    void cancellingChanged(bool cancelling);

private:
    class Private;
    Private *d;
};

#endif // THEMEDOWNLOADER_H
