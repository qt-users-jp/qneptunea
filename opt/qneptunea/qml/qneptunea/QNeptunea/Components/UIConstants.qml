/* Copyright (c) 2012 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 1.1
import QNeptunea 1.0

QtObject {
    id: root

    /*************** theme ***************/
    property string themeId: settings.readData('Theme/ID', '/opt/qneptunea/plugins/theme/default.qml')
    onThemeIdChanged: settings.saveData('Theme/ID', root.themeId)

    property bool themeInverted: settings.readData('Appearance/ThemeInverted', true)
    onThemeInvertedChanged: settings.saveData('Appearance/ThemeInverted', root.themeInverted)
    property int themeColorScheme: settings.readData('Appearance/ThemeColorScheme', 3)
    onThemeColorSchemeChanged: settings.saveData('Appearance/ThemeColorScheme', root.themeColorScheme)

    property ConfItem splashPortraitConf: ConfItem { id: splashPortraitConf; key: '/apps/QNeptunea/Theme/Splash/Portrait' }
    property ConfItem splashLandscapeConf: ConfItem { id: splashLandscapeConf; key: '/apps/QNeptunea/Theme/Splash/Landscape' }
    property string splashPortrait: splashPortraitConf.value
    onSplashPortraitChanged: splashPortraitConf.value = root.splashPortrait
    property string splashLandscape: splashLandscapeConf.value
    onSplashLandscapeChanged: splashLandscapeConf.value = root.splashLandscape

    property url background: window.inPortrait ? root.backgroundPortrait : root.backgroundLandscape
    property url backgroundPortrait: settings.readData('Theme/BackgroundPortrait', '/opt/qneptunea/plugins/theme/default-background-portrait.png')
    onBackgroundPortraitChanged: settings.saveData('Theme/BackgroundPortrait', root.backgroundPortrait)
    property url backgroundLandscape: settings.readData('Theme/BackgroundLandscape', '/opt/qneptunea/plugins/theme/default-background-landscape.png')
    onBackgroundLandscapeChanged: settings.saveData('Theme/BackgroundLandscape', root.backgroundLandscape)

    property int headerHeight: window.inPortrait ? root.headerHeightPortrait : root.headerHeightLandscape
    property int headerHeightPortrait: settings.readData('Theme/HeaderHeightPortrait', 72)
    onHeaderHeightPortraitChanged: settings.saveData('Theme/HeaderHeightPortrait', root.headerHeightPortrait)
    property int headerHeightLandscape: settings.readData('Theme/HeaderHeightLandscape', 46)
    onHeaderHeightLandscapeChanged: settings.saveData('Theme/HeaderHeightLandscape', root.headerHeightLandscape)

    property url logo: window.inPortrait ? root.logoPortrait : root.logoLandscape
    property url logoPortrait: settings.readData('Theme/LogoPortrait', '/opt/qneptunea/plugins/theme/logo-portrait.png')
    onLogoPortraitChanged: settings.saveData('Theme/LogoPortrait', root.logoPortrait)
    property url logoLandscape: settings.readData('Theme/LogoLandscape', '/opt/qneptunea/plugins/theme/logo-landscape.png')
    onLogoLandscapeChanged: settings.saveData('Theme/LogoLandscape', root.logoLandscape)

    property color titleColor: window.inPortrait ? root.titleColorPortrait : root.titleColorLandscape
    property color titleColorPortrait: settings.readData('Theme/TitleColorPortrait', '#FFFFFF')
    onTitleColorPortraitChanged: settings.saveData('Theme/TitleColorPortrait', root.titleColorPortrait)
    property color titleColorLandscape: settings.readData('Theme/TitleColorLandscape', '#FFFFFF')
    onTitleColorLandscapeChanged: settings.saveData('Theme/TitleColorLandscape', root.titleColorLandscape)

    property int titleFontPixelSize: window.inPortrait ? root.titleFontPixelSizePortrait : root.titleFontPixelSizeLandscape
    property int titleFontPixelSizePortrait: settings.readData('Theme/TitleFontPixelSizePortrait', 30)
    onTitleFontPixelSizePortraitChanged: settings.saveData('Theme/TitleFontPixelSizePortrait', root.titleFontPixelSizePortrait)
    property int titleFontPixelSizeLandscape: settings.readData('Theme/TitleFontPixelSizeLandscape', 30)
    onTitleFontPixelSizeLandscapeChanged: settings.saveData('Theme/TitleFontPixelSizeLandscape', root.titleFontPixelSizeLandscape)

    property color textColor: window.inPortrait ? root.textColorPortrait : root.textColorLandscape
    property color textColorPortrait: settings.readData('Theme/TextColorPortrait', '#FFFFFF')
    onTextColorPortraitChanged: settings.saveData('Theme/TextColorPortrait', root.textColorPortrait)
    property color textColorLandscape: settings.readData('Theme/TextColorLandscape', '#FFFFFF')
    onTextColorLandscapeChanged: settings.saveData('Theme/TextColorLandscape', root.textColorLandscape)

    property string linkStyle: window.inPortrait ? root.linkStylePortrait : root.linkStyleLandscape
    property string linkStylePortrait: settings.readData('Theme/LinkStylePortrait', 'font-size: large; text-decoration: none; color: lightblue')
    onLinkStylePortraitChanged: settings.saveData('Theme/LinkStylePortrait', root.linkStylePortrait)
    property string linkStyleLandscape: settings.readData('Theme/LinkStyleLandscape', 'font-size: large; text-decoration: none; color: lightblue')
    onLinkStyleLandscapeChanged: settings.saveData('Theme/LinkStyleLandscape', root.linkStyleLandscape)

    property string hashTagStyle: window.inPortrait ? root.hashTagStylePortrait : root.hashTagStyleLandscape
    property string hashTagStylePortrait: settings.readData('Theme/HashTagStylePortrait', 'font-size: large; text-decoration: none; color: lightpink')
    onHashTagStylePortraitChanged: settings.saveData('Theme/HashTagStylePortrait', root.hashTagStylePortrait)
    property string hashTagStyleLandscape: settings.readData('Theme/HashTagStyleLandscape', 'font-size: large; text-decoration: none; color: lightpink')
    onHashTagStyleLandscapeChanged: settings.saveData('Theme/HashTagStyleLandscape', root.hashTagStyleLandscape)

    property string screenNameStyle: window.inPortrait ? root.screenNameStylePortrait : root.screenNameStyleLandscape
    property string screenNameStylePortrait: settings.readData('Theme/ScreenNameStylePortrait', 'font-size: large; text-decoration: none; color: #CAFF33')
    onScreenNameStylePortraitChanged: settings.saveData('Theme/ScreenNameStylePortrait', root.screenNameStylePortrait)
    property string screenNameStyleLandscape: settings.readData('Theme/ScreenNameStyleLandscape', 'font-size: large; text-decoration: none; color: #CAFF33')
    onScreenNameStyleLandscapeChanged: settings.saveData('Theme/ScreenNameStyleLandscape', root.screenNameStyleLandscape)

    property string sourceStyle: window.inPortrait ? root.sourceStylePortrait : root.sourceStyleLandscape
    property string sourceStylePortrait: settings.readData('Theme/SourceStylePortrait', 'font-size: large; text-decoration: none; color: mediumpurple')
    onSourceStylePortraitChanged: settings.saveData('Theme/SourceStylePortrait', root.sourceStylePortrait)
    property string sourceStyleLandscape: settings.readData('Theme/SourceStyleLandscape', 'font-size: large; text-decoration: none; color: mediumpurple')
    onSourceStyleLandscapeChanged: settings.saveData('Theme/SourceStyleLandscape', root.sourceStyleLandscape)

    property string mediaStyle: window.inPortrait ? root.mediaStylePortrait : root.mediaStyleLandscape
    property string mediaStylePortrait: settings.readData('Theme/MediaStylePortrait', 'font-size: large; text-decoration: none; color: lightyellow')
    onMediaStylePortraitChanged: settings.saveData('Theme/MediaStylePortrait', root.mediaStylePortrait)
    property string mediaStyleLandscape: settings.readData('Theme/MediaStyleLandscape', 'font-size: large; text-decoration: none; color: lightyellow')
    onMediaStyleLandscapeChanged: settings.saveData('Theme/MediaStyleLandscape', root.mediaStyleLandscape)

    property string placeStyle: window.inPortrait ? root.placeStylePortrait : root.placeStyleLandscape
    property string placeStylePortrait: settings.readData('Theme/PlaceStylePortrait', 'font-size: large; text-decoration: none; color: burlywood')
    onPlaceStylePortraitChanged: settings.saveData('Theme/PlaceStylePortrait', root.placeStylePortrait)
    property string placeStyleLandscape: settings.readData('Theme/PlaceStyleLandscape', 'font-size: large; text-decoration: none; color: burlywood')
    onPlaceStyleLandscapeChanged: settings.saveData('Theme/PlaceStyleLandscape', root.placeStyleLandscape)

    property int iconLeftMargin: window.inPortrait ? root.iconLeftMarginPortrait : root.iconLeftMarginPortrait
    property int iconLeftMarginPortrait: settings.readData('Theme/IconLeftMarginPortrait', 0)
    onIconLeftMarginPortraitChanged: settings.saveData('Theme/IconLeftMarginPortrait', root.iconLeftMarginPortrait)
    property int iconLeftMarginLandscape: settings.readData('Theme/IconLeftMarginLandscape', 0)
    onIconLeftMarginLandscapeChanged: settings.saveData('Theme/IconLeftMarginLandscape', root.iconLeftMarginLandscape)

    property color nameColor: window.inPortrait ? root.nameColorPortrait : root.nameColorLandscape
    property color nameColorPortrait: settings.readData('Theme/NameColorPortrait', '#CAFF33')
    onNameColorPortraitChanged: settings.saveData('Theme/NameColorPortrait', root.nameColorPortrait)
    property color nameColorLandscape: settings.readData('Theme/NameColorLandscape', '#CAFF33')
    onNameColorLandscapeChanged: settings.saveData('Theme/NameColorLandscape', root.nameColorLandscape)

    property color contentColor: window.inPortrait ? root.contentColorPortrait : root.contentColorLandscape
    property color contentColorPortrait: settings.readData('Theme/ContentColorPortrait', '#FFFFFF')
    onContentColorPortraitChanged: settings.saveData('Theme/ContentColorPortrait', root.contentColorPortrait)
    property color contentColorLandscape: settings.readData('Theme/ContentColorLandscape', '#FFFFFF')
    onContentColorLandscapeChanged: settings.saveData('Theme/ContentColorLandscape', root.contentColorLandscape)

    property color separatorNormalColor: window.inPortrait ? root.separatorNormalColorPortrait : root.separatorNormalColorLandscape
    property color separatorNormalColorPortrait: settings.readData('Theme/SeparatorNormalColorPortrait', '#FFFFFF')
    onSeparatorNormalColorPortraitChanged: settings.saveData('Theme/SeparatorNormalColorPortrait', root.separatorNormalColorPortrait)
    property color separatorNormalColorLandscape: settings.readData('Theme/SeparatorNormalColorLandscape', '#FFFFFF')
    onSeparatorNormalColorLandscapeChanged: settings.saveData('Theme/SeparatorNormalColorLandscape', root.separatorNormalColorLandscape)

    property color separatorFromMeColor: window.inPortrait ? root.separatorFromMeColorPortrait : root.separatorFromMeColorLandscape
    property color separatorFromMeColorPortrait: settings.readData('Theme/SeparatorFromMeColorPortrait', '#33CAFF')
    onSeparatorFromMeColorPortraitChanged: settings.saveData('Theme/SeparatorFromMeColorPortrait', root.separatorFromMeColorPortrait)
    property color separatorFromMeColorLandscape: settings.readData('Theme/SeparatorFromMeColorLandscape', '#33CAFF')
    onSeparatorFromMeColorLandscapeChanged: settings.saveData('Theme/SeparatorFromMeColorLandscape', root.separatorFromMeColorLandscape)

    property color separatorToMeColor: window.inPortrait ? root.separatorToMeColorPortrait : root.separatorToMeColorLandscape
    property color separatorToMeColorPortrait: settings.readData('Theme/SeparatorToMeColorPortrait', '#FF33CA')
    onSeparatorToMeColorPortraitChanged: settings.saveData('Theme/SeparatorToMeColorPortrait', root.separatorToMeColorPortrait)
    property color separatorToMeColorLandscape: settings.readData('Theme/SeparatorToMeColorLandscape', '#FF33CA')
    onSeparatorToMeColorLandscapeChanged: settings.saveData('Theme/SeparatorToMeColorLandscape', root.separatorToMeColorLandscape)

    property color scrollBarColor: window.inPortrait ? root.scrollBarColorPortrait : root.scrollBarColorLandscape
    property color scrollBarColorPortrait: settings.readData('Theme/ScrollBarColorPortrait', '#9AD400')
    onScrollBarColorPortraitChanged: settings.saveData('Theme/ScrollBarColorPortrait', root.scrollBarColorPortrait)
    property color scrollBarColorLandscape: settings.readData('Theme/ScrollBarColorLandscape', '#9AD400')
    onScrollBarColorLandscapeChanged: settings.saveData('Theme/ScrollBarColorLandscape', root.scrollBarColorLandscape)

    property int fontXLarge: fontDefault * 1.3
    property int fontLarge: fontDefault * 1.2
    property int fontSLarge: fontDefault * 1.1
    property real fontDefault: settings.readData('Appearance/FontSize', 24)
    onFontDefaultChanged: settings.saveData('Appearance/FontSize', constants.fontDefault)
    property int fontLSmall: fontDefault * 0.9
    property int fontSmall: fontDefault * 0.8
    property int fontXSmall: fontDefault * 0.7
    property int fontXXSmall: fontDefault * 0.6

    property int statusBarHeight: window.inPortrait ? 36 : 0

    property int listViewMargins: 4
    property int listViewIconSize: settings.readData('Appearance/IconSize', 48)
    onListViewIconSizeChanged:  settings.saveData('Appearance/IconSize', constants.listViewIconSize)
    property string listViewIconSizeName: settings.readData('Appearance/IconSizeName', 'normal')
    onListViewIconSizeNameChanged:  settings.saveData('Appearance/IconSizeName', constants.listViewIconSizeName)
    property int listViewScrollbarWidth: 5

    property string fontFamily: "Nokia Pure Text"

    property real separatorOpacity: settings.readData('Appearance/SeparatorOpacity', 1.00)
    onSeparatorOpacityChanged: settings.saveData('Appearance/SeparatorOpacity', constants.separatorOpacity)
    property int separatorHeight: 2

    property bool restoringLastPositionDisabled: settings.readData('Power/RestoringLastPositionDisabled', false)
    onRestoringLastPositionDisabledChanged: settings.saveData('Power/RestoringLastPositionDisabled', constants.restoringLastPositionDisabled)

    property bool screenSaverDisabled: settings.readData('Power/ScreenSaverDisabled', true)
    onScreenSaverDisabledChanged: settings.saveData('Power/ScreenSaverDisabled', constants.screenSaverDisabled)

    property bool updateCheckDisabled: settings.readData('Power/UpdateCheckDisabled', false)
    onUpdateCheckDisabledChanged: settings.saveData('Power/UpdateCheckDisabled', constants.updateCheckDisabled)

    property ConfItem syncConf: ConfItem { id: syncConf; key: '/apps/QNeptunea/Sync' }
    property bool sync: typeof syncConf.value === 'undefined' ? true : syncConf.value
    onSyncChanged: syncConf.value = root.sync

    property ConfItem mentionsNotificationConf: ConfItem { id: mentionsNotificationConf; key: '/apps/ControlPanel/QNeptunea/Notification/Mentions' }
    property bool mentionsNotification: mentionsNotificationConf.value
    onMentionsNotificationChanged: mentionsNotificationConf.value = root.mentionsNotification
    property ConfItem messagesNotificationConf: ConfItem { id: messagesNotificationConf; key: '/apps/ControlPanel/QNeptunea/Notification/DirectMessages' }
    property bool messagesNotification: messagesNotificationConf.value
    onMessagesNotificationChanged: messagesNotificationConf.value = root.messagesNotification
    property ConfItem searchesNotificationConf: ConfItem { id: searchesNotificationConf; key: '/apps/ControlPanel/QNeptunea/Notification/SavedSearches' }
    property bool searchesNotification: searchesNotificationConf.value
    onSearchesNotificationChanged: searchesNotificationConf.value = root.searchesNotification

    property bool notificationsWithHapticsFeedback: settings.readData('Notifications/HapticsFeedback', false)
    onNotificationsWithHapticsFeedbackChanged: settings.saveData('Notifications/HapticsFeedback', root.notificationsWithHapticsFeedback)

    property string notificationIconForMentions: settings.readData('Theme/NotificationIconForMentions', 'icon-m-service-qneptunea-mention')
    onNotificationIconForMentionsChanged: settings.saveData('Theme/NotificationIconForMentions', root.notificationIconForMentions)
    property string notificationIconForMessages: settings.readData('Theme/NotificationIconForMessages', 'icon-m-service-qneptunea-message')
    onNotificationIconForMessagesChanged: settings.saveData('Theme/NotificationIconForMessages', root.notificationIconForMessages)
    property string notificationIconForSearches: settings.readData('Theme/NotificationIconForSearches', 'icon-m-service-qneptunea-search')
    onNotificationIconForSearchesChanged: settings.saveData('Theme/NotificationIconForSearches', root.notificationIconForSearches)

    property bool streaming: settings.readData('Connection/Streaming', true)
    onStreamingChanged: settings.saveData('Connection/Streaming', constants.streaming)

    property int updateInterval: settings.readData('Connection/UpdateInterval', 5)
    onUpdateIntervalChanged: settings.saveData('Connection/UpdateInterval', constants.updateInterval)

    property string dateFormat: settings.readData('Appearance/DateFormat', 'd MMM')
    onDateFormatChanged: settings.saveData('Appearance/DateFormat', constants.dateFormat)

    property string timeFormat: settings.readData('Appearance/TimeFormat', 'hh:mm')
    onTimeFormatChanged: settings.saveData('Appearance/TimeFormat', constants.timeFormat)

    property string dateTimeFormat: root.dateFormat.concat(' ').concat(root.timeFormat)
}
