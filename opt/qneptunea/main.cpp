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

#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QTimer>
#include <QtGui/QApplication>
#include <QtGlobal>
#include <QtOpenGL/QGLWidget>
#include <QtDBus/QDBusInterface>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/qdeclarative.h>

#include <twitter4qml.h>

#include "qmlapplicationviewer.h"
#include "server.h"
#include "thumbnailer.h"
#include "networkconfigurationmanager.h"
#include "eventfeed.h"
#include "shareinterface.h"
#include "actionhandler.h"
#include "notification.h"
#include "profileimage.h"
#include "pluginloader.h"
#include "themedownloader.h"
#include "confitem.h"
#include "photouploader.h"

#include <MComponentData>

class AutoTest : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool manual READ manual)
public:
    AutoTest(QObject *parent = 0)
        : QObject(parent)
    {
        if (QApplication::arguments().contains("-test"))
            QTimer::singleShot(10000, this, SIGNAL(start()));
    }

    bool manual() const { return QApplication::arguments().contains("-manual"); }

signals:
    void start();

public slots:
    void end(int exitCode) { QApplication::exit(exitCode); }
};

class Private : public QObject
{
    Q_OBJECT
public:
    explicit Private(QmlApplicationViewer *parent);

public slots:
    void activate();

private:
    QmlApplicationViewer *q;
};

Private::Private(QmlApplicationViewer *parent)
    : QObject(parent)
    , q(parent)
{
}

void Private::activate()
{
    q->activateWindow();
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    MComponentData::createInstance(argc, argv);

    bool background = app->arguments().contains("cron");

    if (background) {
        QDBusInterface dbus_iface("org.freedesktop.DBus", "/org/freedesktop/DBus",
                                  "org.freedesktop.DBus");
        QStringList listNames = dbus_iface.call("ListNames").arguments().at(0).toStringList();
        if (listNames.contains("com.twitter")) return 0;
    }

    app->setOrganizationName(QLatin1String("QNeptunea"));
    app->setOrganizationDomain(QLatin1String("https://gitorious.org/qneptunea"));
    app->setApplicationName(QLatin1String("QNeptunea"));

    Server *server = 0;

    QmlApplicationViewer viewer;

    if (!background) {
        server = new Server(app.data());
        Private *d = new Private(&viewer);
        QObject::connect(server, SIGNAL(activated()), d, SLOT(activate()));
    }

    Twitter4QML twitter4qml;
    twitter4qml.setNetworkAccessManager(viewer.engine()->networkAccessManager());

    qmlRegisterType<ShareInterface>("QNeptunea", 1, 0, "ShareInterface");
    qmlRegisterType<ProfileImage>("QNeptunea", 1, 0, "ProfileImageUrl");
    qmlRegisterType<PluginLoader>("QNeptunea", 1, 0, "PluginLoader");
    qmlRegisterType<Notification>("QNeptunea", 1, 0, "Notification");
    qmlRegisterType<ThemeDownloader>("QNeptunea", 1, 0, "ThemeDownloader");
    qmlRegisterType<ConfItem>("QNeptunea", 1, 0, "ConfItem");
    qmlRegisterType<PhotoUploader>("QNeptunea", 1, 0, "PhotoUploader");
    qmlRegisterType<AutoTest>("QNeptunea", 1, 0, "AutoTest");

//    QDir home("/home/developer");
    QDir home = QDir::home();

    bool customCilent = false;
#if 0
    if (home.exists(QLatin1String(".qneptunea"))) {
        QFile file(home.absoluteFilePath(QLatin1String(".qneptunea")));
        if (file.open(QFile::ReadOnly | QFile::Text)) {
            QTextStream stream(&file);
            QString consumerKey = stream.readLine();
            QString consumerSecret = stream.readLine();
            if (!consumerKey.isEmpty() && !consumerSecret.isEmpty()) {
                viewer.engine()->rootContext()->setContextProperty("consumerKey", consumerKey);
                viewer.engine()->rootContext()->setContextProperty("consumerSecret", consumerKey);
                customCilent = true;
            }
            file.close();
        }
    }
#endif
    if (!customCilent) {
        viewer.engine()->rootContext()->setContextProperty("consumerKey", "IEDrFlcFIxwvSzOz6JJzgg");
        viewer.engine()->rootContext()->setContextProperty("consumerSecret", "CPj6YOXOjFLaR5OvYtkZTiQyrdM6YIUcs17cD1wOM");
    }

    if (background) {
        viewer.setMainQmlFile(QLatin1String("qml/qneptunea-cron/cron.qml"));
    } else {
        NetworkConfigurationManager *networkConfigurationManager = new NetworkConfigurationManager;
        ThemeDownloader::networkAccessManager = viewer.engine()->networkAccessManager();
        ProfileImage::setup(viewer.engine()->networkAccessManager(), networkConfigurationManager);
        viewer.engine()->addImportPath(QLatin1String("/opt/qneptunea/plugins/api/"));
        viewer.engine()->addImportPath(QLatin1String("/opt/qneptunea/qml/qneptunea/"));
        viewer.engine()->addImageProvider(QLatin1String("qneptunea"), new Thumbnailer);
        viewer.engine()->rootContext()->setContextProperty("networkConfigurationManager", networkConfigurationManager);
        viewer.engine()->rootContext()->setContextProperty("ActionHandler", new ActionHandler);
        viewer.engine()->rootContext()->setContextProperty("app", server);
        viewer.engine()->rootContext()->setContextProperty("LANG", QString(qgetenv("LANG")));
        viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

        if (home.exists("qneptunea")) {
            if (home.cd("qneptunea")) {
                if (home.exists("main.qml")) {
                    viewer.setMainQmlFile(home.absoluteFilePath("main.qml"));
                } else {
                    home.cdUp();
                }
            }
        }
        if (home == QDir::home()) {
            viewer.setMainQmlFile(QLatin1String("qml/qneptunea/main.qml"));
        }

        viewer.setAttribute(Qt::WA_OpaquePaintEvent);
        viewer.setAttribute(Qt::WA_NoSystemBackground);
        viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
        viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
        viewer.setViewport(new QGLWidget);

        if (viewer.status() == QDeclarativeView::Error) {
            qWarning() << viewer.errors();
            return 1;
        }

        viewer.showExpanded();
    }
    int ret = app->exec();
    if (!background)
        ProfileImage::cleanup();
    return ret;
}

#include "main.moc"
