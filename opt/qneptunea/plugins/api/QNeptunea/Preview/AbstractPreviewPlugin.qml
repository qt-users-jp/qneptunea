import QtQuick 1.1

StateGroup {
    property string type: ''
    property variant domains: []

    // overload this function in subclasses
    function load(url, domain) {
        console.debug(url, domain)
        // return whether the url is valid
        return false
    }
}

