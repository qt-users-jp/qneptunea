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
