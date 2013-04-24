/* Copyright (c) 2012-2013 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "themedownloader.h"
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QBuffer>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <quazip.h>
#include <quazipfile.h>
#include <twitter4qml_global.h>

class ThemeDownloader::Private : public QObject
{
    Q_OBJECT
public:
    Private(ThemeDownloader *parent);

    void start();
    void cancel();
    void cleanup();

private slots:
    void localPathChanged(const QString &localPath);
    void existsChanged(bool exists);
    void setExists(bool exists);
    void setRunning(bool running);
    void setProgress(int progress);
    void setThemeFile(const QUrl &themeFile);
    void setCancelling(bool cancelling);

    void finished();
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    bool findQmlFile(const QString &path);
    void cleanupDir(const QString &path);

private:
    ThemeDownloader *q;
    QNetworkReply *reply;

public:
    QString localPath;
    QString remoteUrl;
    bool exists;
    bool running;
    int progress;
    QUrl themeFile;
    bool cancelling;
};

QNetworkAccessManager *ThemeDownloader::networkAccessManager = 0;

ThemeDownloader::Private::Private(ThemeDownloader *parent)
    : QObject(parent)
    , q(parent)
    , reply(0)
    , exists(false)
    , running(false)
    , progress(-1)
    , cancelling(false)
{
    connect(q, SIGNAL(localPathChanged(QString)), this, SLOT(localPathChanged(QString)));
    connect(q, SIGNAL(existsChanged(bool)), this, SLOT(existsChanged(bool)));
}

void ThemeDownloader::Private::start()
{
    QNetworkRequest request(remoteUrl);
    reply = networkAccessManager->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(finished()));
    connect(reply, SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(downloadProgress(qint64,qint64)));
    setRunning(true);
    setProgress(0);
}

void ThemeDownloader::Private::cancel()
{
    reply->abort();
    reply->deleteLater();
    reply = 0;
    setCancelling(true);
    setProgress(0);
}

void ThemeDownloader::Private::cleanup()
{
    QDir dir(localPath);
    cleanupDir(localPath);
    QString dirName = dir.dirName();
    DEBUG() << dirName;
    dir.cdUp();
    dir.rmdir(dirName);
    setExists(false);
}

void ThemeDownloader::Private::cleanupDir(const QString &path)
{
    QDir dir(path);
    DEBUG() << dir.absolutePath();
    foreach (const QString &d, dir.entryList(QStringList() << "*", QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks)) {
        cleanupDir(dir.absoluteFilePath(d));
        dir.rmdir(d);
    }
    foreach (const QString &qmlFile, dir.entryList(QStringList() << "*", QDir::Files | QDir::NoSymLinks)) {
        DEBUG() << dir.absoluteFilePath(qmlFile);
        dir.remove(qmlFile);
    }

    foreach (const QString &d, dir.entryList(QStringList() << "*", QDir::Dirs | QDir::NoDotAndDotDot)) {
        DEBUG() << dir.absoluteFilePath(d);
        dir.remove(d);
    }
}


void ThemeDownloader::Private::finished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply != this->reply) {
        setRunning(false);
        return;
    }

    QString qmlFile;
    QDir dir(localPath);
    QBuffer buffer;
    buffer.setData(reply->readAll());
    this->reply = 0;
    QuaZip zip(&buffer);
    zip.open(QuaZip::mdUnzip);
    for (bool more = zip.goToFirstFile(); more; more = zip.goToNextFile()) {
        QString fileName(zip.getCurrentFileName());
        DEBUG() << dir.absoluteFilePath(fileName) << fileName;
        DEBUG() << dir.relativeFilePath(fileName);
        if (fileName.endsWith("/")) {
            // dir
//            dir.mkpath(fileName);
        } else {
            QFileInfo finfo(dir.absoluteFilePath(fileName));
            if (!finfo.absoluteDir().exists()) {
                dir.mkpath(finfo.absoluteDir().absolutePath());
                DEBUG() << finfo.absoluteDir() << finfo.fileName();
            }
            QFile fout(dir.absoluteFilePath(fileName));
            if (fout.open(QIODevice::WriteOnly)) {
                QuaZipFile fin(&zip);
                if (fin.open(QIODevice::ReadOnly)) {
                    fout.write(fin.readAll());
                    fin.close();
                    if (fileName.endsWith(".qml"))
                        qmlFile = fout.fileName();
                } else {
                    DEBUG() << "false";
                }
                fout.close();
            } else {
                DEBUG() << fout.errorString();
            }
        }
    }

    setRunning(false);
    localPathChanged(localPath);
}

void ThemeDownloader::Private::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    if (!reply) return;
    setProgress(bytesReceived * 100 / bytesTotal);
}

void ThemeDownloader::Private::localPathChanged(const QString &localPath)
{
    DEBUG() << localPath << QFile::exists(localPath);
    setExists(QFile::exists(localPath));
}

void ThemeDownloader::Private::existsChanged(bool exists)
{
    DEBUG() << exists;
    if (exists) {
        findQmlFile(localPath);
    } else {
        setThemeFile(QUrl());
    }
}

bool ThemeDownloader::Private::findQmlFile(const QString &path)
{
    DEBUG() << path;
    if (path.endsWith(".qml") && QFile::exists(path)) {
        setThemeFile(path);
        return true;
    }
    QDir dir(path);
    DEBUG() << dir.absolutePath();
    foreach (const QString &d, dir.entryList(QStringList() << "*", QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks)) {
        if (findQmlFile(dir.absoluteFilePath(d))) return true;
    }
    foreach (const QString &qmlFile, dir.entryList(QStringList() << "*.qml", QDir::Files | QDir::NoSymLinks)) {
        DEBUG() << dir.absoluteFilePath(qmlFile);
        setThemeFile(dir.absoluteFilePath(qmlFile));
        return true;
    }
    return false;
}

void ThemeDownloader::Private::setRunning(bool running)
{
    if (this->running == running) return;
    this->running = running;
    emit q->runningChanged(running);
}

void ThemeDownloader::Private::setExists(bool exists)
{
    if (this->exists == exists) return;
    this->exists = exists;
    emit q->existsChanged(exists);
}

void ThemeDownloader::Private::setProgress(int progress)
{
    if (this->progress == progress) return;
    this->progress = progress;
    emit q->progressChanged(progress);
}

void ThemeDownloader::Private::setThemeFile(const QUrl &themeFile)
{
    if (this->themeFile == themeFile) return;
    this->themeFile = themeFile;
    emit q->themeFileChanged(themeFile);
}

void ThemeDownloader::Private::setCancelling(bool cancelling)
{
    if (this->cancelling == cancelling) return;
    this->cancelling = cancelling;
    emit q->cancellingChanged(cancelling);
}

ThemeDownloader::ThemeDownloader(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
}

void ThemeDownloader::start()
{
    d->start();
}

void ThemeDownloader::cancel()
{
    d->cancel();
}

void ThemeDownloader::cleanup()
{
    d->cleanup();
}

const QString &ThemeDownloader::localPath() const
{
    return d->localPath;
}

void ThemeDownloader::setLocalPath(const QString &localPath)
{
    if (d->localPath == localPath) return;
    d->localPath = localPath;
    emit localPathChanged(localPath);
}

const QString &ThemeDownloader::remoteUrl() const
{
    return d->remoteUrl;
}

void ThemeDownloader::setRemoteUrl(const QString &remoteUrl)
{
    DEBUG() << d->remoteUrl << remoteUrl;
    if (d->remoteUrl == remoteUrl) return;
    d->remoteUrl = remoteUrl;
    emit remoteUrlChanged(remoteUrl);
}

bool ThemeDownloader::running() const
{
    return d->running;
}

bool ThemeDownloader::exists() const
{
    return d->exists;
}

int ThemeDownloader::progress() const
{
    return d->progress;
}

const QUrl &ThemeDownloader::themeFile() const
{
    return d->themeFile;
}

bool ThemeDownloader::cancelling() const
{
    return d->cancelling;
}

#include "themedownloader.moc"
