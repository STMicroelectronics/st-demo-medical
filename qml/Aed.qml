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

    /* info */
    Image {
        id: aedInfo
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        source: "/assets/BlowAir_%1/AED_popup.png".arg(constants.assetDir)
    }
    Image {
        id: aedButton
        anchors { horizontalCenter: parent.horizontalCenter; top: aedInfo.bottom }
        anchors.topMargin: - aedButton.height * 1.25
        source: "/assets/BlowAir_%1/Close_normal.png".arg(constants.assetDir)
        MouseArea {
            anchors.fill: parent
            anchors.margins: constants.getPixelSize(-10)
            onPressed: {
                aedButton.source = "/assets/BlowAir_%1/Close_pressed.png".arg(constants.assetDir)
            }
            onReleased: {
                aedButton.source = "/assets/BlowAir_%1/Close_normal.png".arg(constants.assetDir)
                if (stackView.state === 'Aed') {
                    stackView.state = 'Help'
                    if (stackView.depth >= 2) stackView.pop()
                    stackView.push("/qml/Help.qml")
                }
            }
            onCanceled: {
                aedButton.source = "/assets/BlowAir_%1/Close_normal.png".arg(constants.assetDir)
            }
        }
    }

}
