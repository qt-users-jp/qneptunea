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

import QtQuick 1.1

QtObject {
    id: root
    property string identifier: 'Settings'
    property string description: ''
    property string version

    function readData(key, defaultValue) {
        var ret = defaultValue;
        var db = openDatabaseSync(identifier, version, description, 10000);
        db.readTransaction(
            function(tx) {
                        try {
                            var rs = tx.executeSql('SELECT value FROM Settings WHERE key=?', [key]);

                            if (rs.rows.length > 0) {
                                ret = rs.rows.item(0).value;
                            }
                        } catch(e) {}
            }
        )
        return ret;
    }

    function saveData(key, value) {
        var db = openDatabaseSync(identifier, version, description, 10000);
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(key TEXT, value TEXT)');

                var currentValue;
                var rs = tx.executeSql('SELECT value FROM Settings WHERE key=?', [key]);

                if (rs.rows.length > 0) {
                    currentValue = rs.rows.item(0).value;
                }

                if (currentValue !== value) {
                    if (currentValue !== undefined) {
                        tx.executeSql('UPDATE Settings SET value = ? WHERE key = ?', [ value, key ]);
                    } else {
                        tx.executeSql('INSERT INTO Settings VALUES(?, ?)', [ key, value ]);
                    }
                }
            }
        )
    }
}

