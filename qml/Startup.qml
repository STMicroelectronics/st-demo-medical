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

    /* demo mode */
    property bool demoMode: false

    Component.onCompleted:
    {
        /* Restart full scenario */
        fullStatus = statusEnum['Start']

        /* Internal state machine */
        if (root.state == '') {root.state = 'start'}
    }

    /* state machine for Startup */
    states: [
        State {
            name: "start"
            PropertyChanges {
                target: statusBar
                visible: false
            }
        }
    ]

    /* Man with graphical effects */
    ManEffects {
        id: man
        anchors.fill: parent
    }

    /* Startup text message */
    Text {
        id: msg
        anchors.centerIn: parent
        text: qsTr("bob is unconscious and irresponsive")
        color: "white"
        fontSizeMode: Text.FixedSize
        font.pointSize: constants.getPixelSize(30)
        font.family: myFont.name
        opacity: 0
        OpacityAnimator {
            target: msg
            from: 0
            to: 1
            duration: 1500
            running: true
        }
    }

    /* startup message */
    Image {
        id: startup
        anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
        anchors.bottomMargin: parent.height / 20
        source: "/assets/BlowAir_%1/Start_demo_button_normal.png".arg(constants.assetDir)

        MouseArea {
            anchors.fill: parent
            onPressed: {
                startup.source = "/assets/BlowAir_%1/Start_demo_button_pressed.png".arg(constants.assetDir)
            }
            onReleased: {
                startup.source = "/assets/BlowAir_%1/Start_demo_button_normal.png".arg(constants.assetDir)
                stackView.state = 'Help'
                if (stackView.depth >= 2) stackView.pop()
                stackView.push("/qml/Help.qml")
            }
            onCanceled: {
                startup.source = "/assets/BlowAir_%1/Start_demo_button_normal.png".arg(constants.assetDir)
            }
        }
    }

    /* demo mode timer */
    Timer {
        id: demoTimer
        running: demoMode
        interval: 3000
        repeat: false
        onTriggered: {
            /* Push next step */
            stackView.state = 'HeartRate'
            if (stackView.depth >= 2) stackView.pop()
            stackView.push("/qml/HeartRate.qml", {"demoModeVideo": "true"})
        }
    }

}
