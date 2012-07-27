import QtQuick 1.1

StateGroup {
    property string service
    property url url
    property string result

    // overload this function in subclasses
    function translate(richText, plainText, to, from) {
        console.debug(richText, to, from)
    }
}

