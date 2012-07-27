import QtQuick 1.1
import com.nokia.meego 1.0
import "../Delegates"

AbstractListView {
    id: root
    width: 400
    height: 700

    property bool active: false

    delegate: StatusDelegate {
        id: delegate
        width: ListView.view.width
        item: model
        user: model.user
        onClicked: root.showDetail(item)
        onLinkActivated: root.linkActivated(link)

        onPressAndHold: {
            console.debug(model.text)
            console.debug(model.plain_text)
            console.debug(model.rich_text)
            console.debug('http://twitter.com/' + model.user.screen_name + '/' + model.id_str)
        }

        property int height2: delegate.height
        property bool wasAtYBeginning: false

        ListView.onAdd: SequentialAnimation {
            ScriptAction {
                script: {
                    delegate.wasAtYBeginning = delegate.ListView.view.atYBeginning && !root.active
                    if (delegate.wasAtYBeginning) delegate.ListView.view.contentY += 1
                }
            }
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "height2"; value: height }
            PropertyAction { target: delegate; property: "height"; value: 0 }
            NumberAnimation { target: delegate; property: "height"; to: delegate.height2; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "clip"; value: false }
            ScriptAction { script: if (delegate.wasAtYBeginning) delegate.ListView.view.contentY -= 1 }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: delegate; property: "clip"; value: true }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: delegate; property: "height"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: delegate; property: "clip"; value: false }
        }
    }
}
