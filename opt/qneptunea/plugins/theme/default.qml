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
import QNeptunea.Theme 1.0

ThemePlugin {
    id: plugin

    title: 'QNeptunea'
    author: '@LogonAniket'
    property string description: qsTr('Default Green Theme')
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
    titleFontPixelSizeLandscape: 23

    logoPortrait: 'logo-portrait.png'
    logoLandscape: 'logo-landscape.png'

    linkStyle: 'font-size: large; text-decoration: none; color: lightblue'
    hashTagStyle: 'font-size: large; text-decoration: none; color: lightpink'
    screenNameStyle: 'font-size: large; text-decoration: none; color: #CAFF33'
    sourceStyle: 'font-size: large; text-decoration: none; color: mediumpurple'
    mediaStyle: 'font-size: large; text-decoration: none; color: lightyellow'
    placeStyle: 'text-decoration: none; color: burlywood'
}
