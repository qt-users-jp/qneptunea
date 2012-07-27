import QtQuick 1.1
import QtMobility.gallery 1.1
import '../QNeptunea/Components/'

AbstractPage {
    id: root

    title: qsTr('Gallery')
    busy: model.status === DocumentGalleryModel.Active

    GridView {
        id: view
        anchors.fill: parent; anchors.topMargin: root.headerHeight; anchors.bottomMargin: root.footerHeight
        cellWidth: 160
        cellHeight: 160
        cacheBuffer: Math.max(width, height) * 5
        clip: true

        delegate: Image {
            width: 160
            height: 160
            source: 'image://qneptunea/' + url
            asynchronous: true
            clip: true
            cache: false
            fillMode: Image.PreserveAspectCrop
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mediaSelected = url
                    pageStack.pop()
                }
            }
        }

        model: DocumentGalleryModel {
            id: model
            rootType: DocumentGallery.Image
            properties: ["url"]
            sortProperties: ["-lastModified"]
            filter: GalleryWildcardFilter {
                property: "fileName"
                value: "*.*"
            }
        }
    }

    toolBarLayout: AbstractToolBarLayout { backOnly: true }
}
