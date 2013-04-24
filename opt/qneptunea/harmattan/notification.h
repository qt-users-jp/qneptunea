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
