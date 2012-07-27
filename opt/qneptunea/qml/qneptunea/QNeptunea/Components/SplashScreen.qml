// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Image {
    id: root
    width: 854
    height: 480
    Timer {
        id: timer
        running: true
        repeat: false
        interval: 1000
    }

    source: constants.splashPortrait
    fillMode: Image.PreserveAspectFit
    rotation: 90
    smooth: true
    visible: opacity > 0.0
    states: [
        State {
            when: !timer.running
            PropertyChanges {
                target: root
                opacity: 0.0
            }
        },

        State {
            name: "landscape"
            when: !window.inPortrait
            PropertyChanges {
                target: root
                source: constants.splashLandscape
                rotation: 0
                width: 480
                height: 854
            }
        }
    ]
    transitions: [
        Transition {
            NumberAnimation { properties: 'opacity'; duration: 1500 }
        }
    ]
}
