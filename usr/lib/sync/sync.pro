TEMPLATE = lib
TARGET = qneptunea-client
PKGCONFIG += synccommon syncprofile syncpluginmgr
CONFIG += link_pkgconfig

CONFIG += plugin meegotouchevents meegotouch

QT += dbus network
QT -= gui

#input
HEADERS += \
    $$PWD/qneptunea.h
SOURCES += \
    $$PWD/qneptunea.cpp

#install
target.path = /usr/lib/sync/
INSTALLS += target

QMAKE_CXXFLAGS = -Wall \
    -g \
    -Wno-cast-align \
    -O2 -finline-functions

include(../../../etc/etc.pri)
include(../../share/share.pri)
contains(MEEGO_EDITION,harmattan) {
    target.path = /usr/lib/sync
    INSTALLS += target
}
