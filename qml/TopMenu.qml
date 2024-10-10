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
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    /* top menu and buttons */
    Image {
        id: topMenu
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        source: "/assets/HeartRate_%1/top_menu.png".arg(constants.assetDir)
        fillMode: Image.Stretch
        width: parent.width
        z: 2

        /* Performance monitoring */
        RowLayout {
            anchors { right: parent.right; top: parent.top }
            anchors.topMargin: constants.getPixelSize(6)
            anchors.rightMargin: constants.getPixelSize(40)
            spacing: constants.getPixelSize(60)
            visible: !_noperf
            Text {
                id: gpuText
                text: "gpu: "
                color: constants.blueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(18)
                font.family: myFont.name
                visible: (systemInfo.gpuPercent != -1)
                Text {
                    id: gpuTextNb
                    anchors.left: parent.right
                    text: systemInfo.gpuPercent + "%"
                    color: constants.highlightedBlueColor
                    fontSizeMode: Text.FixedSize
                    font.pointSize: constants.getPixelSize(18)
                    font.family: myFont.name
                }
            }
            Text {
                id: mpuText
                text: "cpu: "
                color: constants.blueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(18)
                font.family: myFont.name
                visible: (systemInfo.percent != -1)
                Text {
                    id: mpuTextNb
                    anchors.left: parent.right
                    text: systemInfo.percent  + "%"
                    color: constants.highlightedBlueColor
                    fontSizeMode: Text.FixedSize
                    font.pointSize: constants.getPixelSize(18)
                    font.family: myFont.name
                }
            }
            Text {
                id: fpsText
                text: "fps: "
                color: constants.blueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(18)
                font.family: myFont.name
                Text {
                    id: fpsTextNb
                    anchors.left: parent.right
                    text: systemInfo.fps
                    color: constants.highlightedBlueColor
                    fontSizeMode: Text.FixedSize
                    font.pointSize: constants.getPixelSize(18)
                    font.family: myFont.name
                }
            }
        }

    }

}
