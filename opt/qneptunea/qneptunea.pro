include(../../twitter4qml/twitter4qml.pri)
include(./harmattan/harmattan.pri)
include(../../3rdparty/quazip-0.4.4/quazip/quazip.pri)

# Add more folders to ship with the application, here
folder_01.source = qml/qneptunea
folder_01.target = qml
DEPLOYMENTFOLDERS += folder_01
folder_02.source = qml/qneptunea-share
folder_02.target = qml
DEPLOYMENTFOLDERS += folder_02
folder_03.source = qml/qneptunea-cron
folder_03.target = qml
DEPLOYMENTFOLDERS += folder_03
folder_04.source = plugins/api plugins/preview plugins/translation plugins/theme plugins/service plugins/settings plugins/tweet
folder_04.target = plugins
DEPLOYMENTFOLDERS += folder_04

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp server.cpp \
    themedownloader.cpp \
    photouploader.cpp
HEADERS += server.h \
    themedownloader.h \
    photouploader.h

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

icon64.files = qneptunea64.png
icon64.path = /usr/share/icons/hicolor/64x64/apps
icon256.files = qneptunea256.png
icon256.path = /usr/share/icons/hicolor/256x256/apps
iconsvg.files = qneptunea.svg
iconsvg.path = /usr/share/icons/hicolor/scalable/apps
launcher.files = qneptunea.sh
launcher.path = /opt/qneptunea/bin
INSTALLS += icon64 icon256 iconsvg launcher

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    plugins/api/QNeptunea/Translation/AbstractTranslationPlugin.qml \
    plugins/translation/mstranslatorv2.qml \
    plugins/theme/api/AbstractThemePlugin.qml \
    plugins/api/QNeptunea/Theme/qmldir \
    plugins/api/QNeptunea/Preview/qmldir \
    plugins/api/QNeptunea/Translation/qmldir \
    qneptunea.sh \
    plugins/service/50_getpocket.qml \
    plugins/settings/50_getpocket.qml

QT += dbus opengl sql

RESOURCES += \
    qneptunea.qrc
