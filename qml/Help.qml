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

    /* completion signal */
    signal signalHelpCompleted()

    Component.onCompleted:
    {
        /* On each screen push, we reset internal completion status */
        helpCompleted = false

        /* current screen state machine */
        root.state = 'Start'
    }

    /* state machine for screens */
    states: [
        State {
            name: "Start"
            PropertyChanges {
                target: finger
                rotation: 0
            }
        },
        State {
            name: "Call"
            PropertyChanges {
                target: finger
                rotation: -45
            }
            PropertyChanges {
                target: callHelp
                source: "/assets/BlowAir_%1/speak_call_help_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: callHelp
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
        },
        State {
            name: "Aed"
            PropertyChanges {
                target: finger
                rotation: 45
            }
            PropertyChanges {
                target: getAed
                source: "/assets/BlowAir_%1/speak_get_aed_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: getAed
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
        },
        State {
            name: "FinalAed"
            PropertyChanges {
                target: finger
                rotation: -45
            }
            PropertyChanges {
                target: callHelp
                source: "/assets/BlowAir_%1/speak_call_help_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: callHelp
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
            PropertyChanges {
                target: getAed
                source: "/assets/BlowAir_%1/speak_get_aed_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: getAed
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
            }
        },
        State {
            name: "FinalCall"
            PropertyChanges {
                target: finger
                rotation: 45
            }
            PropertyChanges {
                target: callHelp
                source: "/assets/BlowAir_%1/speak_call_help_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: callHelp
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
            PropertyChanges {
                target: getAed
                source: "/assets/BlowAir_%1/speak_get_aed_active.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: getAed
                anchors.verticalCenterOffset: constants.getPixelSize(-40)
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
            }
        }
    ]

    /* finger */
    Image {
        id: finger
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        source: "/assets/BlowAir_%1/pointing_hand.png".arg(constants.assetDir)
    }

    Image {
        id: callHelp
        anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        anchors.rightMargin: constants.getPixelSize(20)
        source: "/assets/BlowAir_%1/speak_call_help_normal.png".arg(constants.assetDir)
        SequentialAnimation on source {
            NumberAnimation {
                target: callHelp
                property: "opacity"
                from: 1; to: 0
                duration: 0
            }
            NumberAnimation {
                target: callHelp
                property: "opacity"
                from: 0; to: 1
                duration: 500
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.state == 'Start') {
                    root.state = 'Call'
                }
                else if (root.state == 'Aed') {
                    root.state = 'FinalAed'
                    signalHelpCompleted()
                }
            }
        }
    }

    Image {
        id: getAed
        anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        anchors.leftMargin: constants.getPixelSize(20)
        source: "/assets/BlowAir_%1/speak_get_aed_normal.png".arg(constants.assetDir)
        SequentialAnimation on source {
            NumberAnimation {
                target: getAed
                property: "opacity"
                from: 1; to: 0
                duration: 0
            }
            NumberAnimation {
                target: getAed
                property: "opacity"
                from: 0; to: 1
                duration: 500
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.state == 'Start') {
                    root.state = 'Aed'
                }
                else if (root.state == 'Call') {
                    root.state = 'FinalCall'
                    signalHelpCompleted()
                }
            }
        }
    }

}
