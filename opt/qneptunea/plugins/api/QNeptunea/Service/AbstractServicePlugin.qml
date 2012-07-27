import QtQuick 1.1

StateGroup {
    id: root
    property string service
    property url icon
    property bool loading: false
    property bool result: false
    property string message

    function matches(url) {
        return true
    }

    // overload this function in subclasses
    function open(link, parameters) {
        console.debug(link, parameters)
    }
}

