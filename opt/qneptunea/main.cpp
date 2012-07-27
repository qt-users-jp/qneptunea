#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QSettings>
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
//    MComponentData::createInstance(argc, argv);

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
        ThemeDownloader::networkAccessManager = viewer.engine()->networkAccessManager();
        ProfileImage::setup(viewer.engine()->networkAccessManager());
        viewer.engine()->addImportPath(QLatin1String("/opt/qneptunea/plugins/api/"));
        viewer.engine()->addImportPath(QLatin1String("/opt/qneptunea/qml/qneptunea/"));
        viewer.engine()->addImageProvider(QLatin1String("qneptunea"), new Thumbnailer);
        viewer.engine()->rootContext()->setContextProperty("networkConfigurationManager", new NetworkConfigurationManager);
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
