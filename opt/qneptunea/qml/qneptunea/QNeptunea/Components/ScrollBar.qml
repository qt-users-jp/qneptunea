import QtQuick 1.1

Rectangle {
    id: scrollBar
    property Flickable target
    anchors.top: target.top
    anchors.right: target.right
    width: constants.listViewScrollbarWidth
    height: Math.min(target.height, target.height * target.contentY / (target.contentHeight - target.height))
    radius: 2
    smooth: true
    color: constants.scrollBarColor
    opacity: 0.75
    visible: target.visible
    z: 1
}

