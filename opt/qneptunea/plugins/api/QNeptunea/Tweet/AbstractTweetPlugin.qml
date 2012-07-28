import QtQuick 1.1

StateGroup {
    id: root
    property string name
    property url icon
    property bool enabled: true
    property bool visible: true
    property bool loading: false
    property string message

    property string text
    property variant media: []
    property variant location

    // overload this function in subclasses
    function exec() {
        console.debug(text, media, location)
    }
}

