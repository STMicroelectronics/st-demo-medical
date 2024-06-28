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
import QtQuick.Controls 2.15


SwitchDelegate {
    id: control
    checked: false

    contentItem: Text {
        rightPadding: control.indicator.width + control.spacing
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: control.checked ? constants.highlightedBlueColor : constants.blueColor
        fontSizeMode: Text.FixedSize
        font.pointSize: constants.getPixelSize(15)
        font.family: myFont.name
    }

    indicator: Rectangle {
        implicitWidth: constants.getPixelSize(32)
        implicitHeight: constants.getPixelSize(16)
        x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: constants.getPixelSize(8)
        color: control.checked ? constants.highlightedBlueColor : constants.blueColor
        //border.color: control.checked ? constants.highlightedBlueColor : constants.blueColor

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: constants.getPixelSize(16)
            height: constants.getPixelSize(16)
            radius: constants.getPixelSize(8)
            color:  "white"
            //border.color: control.checked ? (control.down ? constants.highlightedBlueColor : constants.blueColor) : "white"
        }
    }

    background: Rectangle {
        visible: control.down || control.highlighted
        color: "transparent"
    }
}


