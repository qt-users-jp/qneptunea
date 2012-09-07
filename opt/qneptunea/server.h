/* Copyright (c) 2012 QNeptunea Project.
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

#ifndef SERVER_H
#define SERVER_H

#include <QtCore/QObject>
#include <QtCore/QVariantList>

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.twitter")
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(QVariantList translations READ translations NOTIFY translationsChanged)
    Q_PROPERTY(QVariantMap translation READ translation WRITE setTranslation NOTIFY translationChanged)
public:
    explicit Server(QObject *parent = 0);
    ~Server();
    
    bool visible() const;
    const QVariantList &translations() const;
    const QVariantMap &translation() const;

    Q_INVOKABLE bool isDeveloper(const QString &screen_name) const;

public slots:
    void listen();
    void launchWithLink(const QStringList &url);
    void mentions();
    void messages();
    void searches();
    void activate();
    void setVisible(bool visible);
    void setTranslation(const QVariantMap &translation);

signals:
    void openUrl(const QStringList &url);
    void activated();
    void visibleChanged(bool visible);
    void translationsChanged(const QVariantList &translation);
    void translationChanged(const QVariant &translation);

private:
    class Private;
    Private *d;
};

#endif // SERVER_H
