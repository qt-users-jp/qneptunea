#include "actionhandler.h"
#include <contentaction.h>

ActionHandler::ActionHandler(QObject *parent)
    : QObject(parent)
{
}

void ActionHandler::openUrlExternally(const QString &url)
{
    ContentAction::Action::defaultActionForString(url).trigger();
}
