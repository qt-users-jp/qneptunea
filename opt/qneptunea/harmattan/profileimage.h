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

#ifndef PROFILEIMAGE_H
#define PROFILEIMAGE_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class QNetworkAccessManager;
class NetworkConfigurationManager;

class ProfileImage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QUrl _id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QUrl cache READ cache NOTIFY cacheChanged)
public:
    static void setup(QNetworkAccessManager *networkAccessManager, NetworkConfigurationManager *networkConfigurationManager);
    static void cleanup();
    explicit ProfileImage(QObject *parent = 0);

    const QUrl &source() const;
    const QUrl &id() const;
    const QUrl &cache() const;

public slots:
    void setSource(const QUrl &source);
    void setId(const QUrl &id);
    void clearCache();

signals:
    void sourceChanged(const QUrl &source);
    void idChanged(const QUrl &id);
    void cacheChanged(const QUrl &cache);

public:
    class Private;
private:
    Private *d;
};

#endif // PROFILEIMAGE_H
