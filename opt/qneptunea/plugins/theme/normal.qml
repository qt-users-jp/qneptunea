import QtQuick 1.1
import QNeptunea.Theme 1.0

ThemePlugin {
    id: plugin
    iconLeftMargin: 5

    title: 'QNeptunea'
    author: 'QNeptuneaTheme'
    property string description: 'Light theme for QNeptunea.'
    property url preview: 'normal.png'

    inverted: false

    separatorToMeColor: '#FF33CA'
    separatorNormalColor: '#191919'
    separatorFromMeColor: '#33CAFF'
    scrollBarColor: 'green'
    nameColor: 'green'
    textColor: '#191919'
    inPortrait: true
    contentColor: '#191919'

    splashPortrait: 'splash-portrait.png'
    splashLandscape: 'splash-landscape.png'

    backgroundPortrait: 'normal-background-portrait.png'
    backgroundLandscape: 'normal-background-landscape.png'

    headerHeightPortrait: 72
    headerHeightLandscape: 46

    titleColor: '#FFFFFF'
    titleFontPixelSizePortrait: 30
    titleFontPixelSizeLandscape: 30

    logoPortrait: 'logo-portrait.png'
    logoLandscape: 'logo-landscape.png'

    linkStyle: 'font-size: large; text-decoration: none; color: darkblue'
    hashTagStyle: 'font-size: large; text-decoration: none; color: deeppink'
    screenNameStyle: 'font-size: large; text-decoration: none; color: green'
    sourceStyle: 'font-size: large; text-decoration: none; color: purple'
    mediaStyle: 'font-size: large; text-decoration: none; color: goldenrod'
    placeStyle: 'text-decoration: none; color: saddlebrown'
}
