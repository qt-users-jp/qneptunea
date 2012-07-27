import QtQuick 1.1
import QNeptunea.Theme 1.0

ThemePlugin {
    id: plugin

    title: 'QNeptunea'
    author: 'QNeptuneaTheme'
    property string description: 'The default theme for QNeptunea.'
    property url preview: 'default.png'

    separatorToMeColor: '#FF33CA'
    separatorNormalColor: '#FFFFFF'
    separatorFromMeColor: '#33CAFF'
    scrollBarColor: '#9AD400'
    nameColor: '#CAFF33'
    textColor: '#FFFFFF'
    inPortrait: true
    contentColor: '#FFFFFF'

    splashPortrait: 'splash-portrait.png'
    splashLandscape: 'splash-landscape.png'

    backgroundPortrait: 'default-background-portrait.png'
    backgroundLandscape: 'default-background-landscape.png'

    headerHeightPortrait: 72
    headerHeightLandscape: 46

    titleColor: '#FFFFFF'
    titleFontPixelSizePortrait: 30
    titleFontPixelSizeLandscape: 30

    logoPortrait: 'logo-portrait.png'
    logoLandscape: 'logo-landscape.png'

    linkStyle: 'font-size: large; text-decoration: none; color: lightblue'
    hashTagStyle: 'font-size: large; text-decoration: none; color: lightpink'
    screenNameStyle: 'font-size: large; text-decoration: none; color: #CAFF33'
    sourceStyle: 'font-size: large; text-decoration: none; color: mediumpurple'
    mediaStyle: 'font-size: large; text-decoration: none; color: lightyellow'
    placeStyle: 'text-decoration: none; color: burlywood'
}
