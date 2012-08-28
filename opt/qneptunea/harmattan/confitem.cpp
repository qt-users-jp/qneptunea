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

#include "confitem.h"
#include <MGConfItem>

ConfItem::ConfItem(QObject *parent)
    : QObject(parent)
    , conf(0)
{
}

QString ConfItem::key() const
{
    if (conf) {
        return conf->key();
    }
    return QString();
}

QVariant ConfItem::value() const
{
    if (conf) {
        return conf->value();
    }
    return QVariant();
}

void ConfItem::setKey(const QString &key)
{
    if (this->key() == key) return;
    if (conf) {
        delete conf;
    }
    conf = new MGConfItem(key, this);
    connect(conf, SIGNAL(valueChanged()), this, SIGNAL(valueChanged()));
    emit keyChanged(key);
}

void ConfItem::setValue(const QVariant &value)
{
    if (this->value() == value) return;
    if (!conf) {
        conf = new MGConfItem(key(), this);
        connect(conf, SIGNAL(valueChanged()), this, SIGNAL(valueChanged()));
    }
    conf->set(value);
}
