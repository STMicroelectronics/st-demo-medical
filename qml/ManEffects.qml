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
// Qt 5 import QtGraphicalEffects 1.15

Item {
    id: root

    /* man with effects */
    Rectangle {
        id: manRectangle
        anchors.fill: parent
        color: "transparent"
        Image {
            id: man
            anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
            source: "/assets/HeartRate_%1/main_man_screen_overlay_effect.png".arg(constants.assetDir)
        }
    }

}
