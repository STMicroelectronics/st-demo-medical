/*
 * @attention
 *
 * Copyright (c) 2024 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 */

import QtQuick 2.15
import QtQuick.Window 2.15

QtObject {
    /*
       Assets are dedicated to 600p and 1920p width screen resolution
       Other resolutions (higher to 600p) will work:
            - between 600p and 1920p: 600p assets used
            - higher to 1920p: 1920p assets used
    */
    readonly property bool changeWindowSize: false // true for testing purpore

    readonly property int screenWidth: changeWindowSize ? 1024 : Screen.width  // or for testing purpore 1920, 1280
    readonly property int screenHeight: changeWindowSize ? 600 : Screen.height // or for testing purpore 1080, 720

    readonly property int minScreenWidth: 1024
    readonly property int minScreenHeight: 600

    property string assetDir: (screenWidth >= 1920) ? "1920" : "1024"
    property string assetVideoDir: (Screen.width == 1280) ? "1280" : assetDir // dedicated video for 720p to avoid resize

    /* If verboseMode is true, console.debug() will output */
    property bool verboseMode: _debugMsg ? true : false

    /* Graphical blend effect, used man and face */
    property bool blendEffect: false

    /* Self demo mode */
    property bool selfDemoMode: false

    /* text color */
    readonly property color blueColor: "#ff0d3e70"
    readonly property color highlightedBlueColor: "#ff4c8cbf"

    /* man size */
    readonly property int manWidth: (screenWidth >= 1920) ? 820 : 456
    readonly property int manHeight: (screenWidth >= 1920) ? 1080 : 600

    /* Ponderate pixel size for other resolution (base is 1024 width) */
    function getPixelSize(basePixelSize) {
        var factor = screenWidth/minScreenWidth

        var pixelSize = Math.floor(basePixelSize * factor)
        //console.log("Pixel size is " + pixelSize)
        return pixelSize
    }
}

