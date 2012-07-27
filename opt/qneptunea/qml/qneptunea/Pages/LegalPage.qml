import QtQuick 1.1
import com.nokia.meego 1.0
import Twitter4QML 1.0
import '../QNeptunea/Components/'
import '../Views'

AbstractPage {
    id: root

    title: qsTr('Legal')
    busy: privacy.loading || tos.loading

    Privacy { id: privacy }
    Tos { id: tos }

    Flickable {
        id: flickable
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        contentHeight: contents.height
        clip: true
        Text {
            id: contents
            width: parent.width
            wrapMode: Text.Wrap
            text: privacy.privacy
            font.family: constants.fontFamily
            font.pixelSize: constants.fontDefault
            color: constants.textColor
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    toolBarLayout: AbstractToolBarLayout {
        ButtonRow {
            TabButton {
                text: qsTr('Privacy')
                checkable: true
                checked: true
                onCheckedChanged: if (checked) contents.text = privacy.privacy
            }
            TabButton {
                text: qsTr('Tos')
                checkable: true
                onCheckedChanged: if (checked) contents.text = tos.tos
            }
        }
    }
}
