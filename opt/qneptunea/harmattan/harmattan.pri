INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD

CONFIG += meegotouch meegotouchevents shareuiinterface-maemo-meegotouch mdatauri
PKGCONFIG += contentaction-0.1

SOURCES += \
    $$PWD/thumbnailer.cpp \
    $$PWD/networkconfigurationmanager.cpp \
    $$PWD/eventfeed.cpp \
    $$PWD/shareinterface.cpp \
    $$PWD/actionhandler.cpp \
    $$PWD/notification.cpp \
    $$PWD/profileimage.cpp \
    $$PWD/pluginloader.cpp \
    harmattan/confitem.cpp

HEADERS += \
    $$PWD/thumbnailer.h \
    $$PWD/networkconfigurationmanager.h \
    $$PWD/eventfeed.h \
    $$PWD/shareinterface.h \
    $$PWD/actionhandler.h \
    $$PWD/notification.h \
    $$PWD/profileimage.h \
    $$PWD/pluginloader.h \
    harmattan/confitem.h

