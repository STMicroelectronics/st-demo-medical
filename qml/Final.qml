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
import QtGraphicalEffects 1.15
import QtMultimedia 5.15

Item {
    id: root

    /* demo mode */
    property bool demoMode: false

    /* Man with graphical effects */
    ManEffects {
        id: man
        anchors.fill: parent

        Image {
            id: bobIsFine
            anchors { horizontalCenter:  parent.horizontalCenter; bottom: msg.top }
            source: "/assets/BlowAir_%1/bob_is_fine_overlay.png".arg(constants.assetDir)
        }

        Text {
            id: msg
            anchors.centerIn: parent
            text: qsTr("you dit it! bob is feeling better")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
    }

    /* startup message */
    Image {
        id: startup
        anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
        anchors.bottomMargin: parent.height / 20
        source: "/assets/BlowAir_%1/Restart_demo_button_normal.png".arg(constants.assetDir)

        MouseArea {
            anchors.fill: parent
            onPressed: {
                startup.source = "/assets/BlowAir_%1/Restart_demo_button_pressed.png".arg(constants.assetDir)
            }
            onReleased: {
                startup.source = "/assets/BlowAir_%1/Restart_demo_button_normal.png".arg(constants.assetDir)
                stackView.pop(null)
                stackView.state = 'Startup'
                stackView.push("/qml/Startup.qml")
            }
            onCanceled: {
                startup.source = "/assets/BlowAir_%1/Restart_demo_button_normal.png".arg(constants.assetDir)
            }
        }
    }

    /* demo mode timer */
    Timer {
        id: demoTimer
        running: demoMode
        interval: 4000
        repeat: false
        onTriggered: {
            /* Push next step */
            stackView.pop(null)
            stackView.state = 'Startup'
            stackView.push("/qml/Startup.qml", {"demoMode": "true"})
        }
    }

}
