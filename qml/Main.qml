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
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import SystemInfo 1.0

Window {
    id: window
    width: constants.screenWidth
    height: constants.screenHeight
    minimumWidth: constants.minScreenWidth
    minimumHeight: constants.minScreenHeight
    visibility: _windowVisibility ? ApplicationWindow.Windowed : ApplicationWindow.FullScreen
    visible: true
    color: "black"

    /* Store info of already completed stages */
    property bool helpCompleted: false
    property bool heartRateCompleted: false
    property bool secureAirwaysCompleted: false
    property bool blowAirCompleted: false

    /* Full scenario status */
    property variant statusEnum: { 'Start': 1, 'Heart1': 2, 'Blow1': 3, 'Heart2': 4, 'Blow2': 5, 'Final': 6 }
    property int fullStatus: statusEnum['Start']

    /* Set correct status bar */
    function setStatusBar() {
        if (fullStatus >= statusEnum['Start'] && fullStatus <= statusEnum['Final']) {
            statusBar.source = "/assets/BlowAir_%1/button_progress_bar_%2.png".arg(constants.assetDir).arg(fullStatus)
        }
        else {
            statusBar.source = "/assets/BlowAir_%1/button_progress_bar_1.png".arg(constants.assetDir)
        }
    }

    Connections {
        id: signalCompletionHandler
        target: stackView.currentItem
        ignoreUnknownSignals: true
        function onSignalHelpCompleted() {
            helpCompleted = true
            setStatusBar()
        }
        function onSignalHeartRateCompleted() {
            if (constants.verboseMode) console.debug("HeartRate handler entry: ", fullStatus)
            heartRateCompleted = true
            if (fullStatus > statusEnum['Heart1']) {
                fullStatus = statusEnum['Heart2']
            }
            else {
                fullStatus = statusEnum['Heart1']
            }
            if (constants.verboseMode) console.debug("HeartRate handler exit: ", fullStatus)
            setStatusBar()
        }
        function onSignalSecureAirwaysCompleted() {
            secureAirwaysCompleted = true
            setStatusBar()
        }
        function onSignalBlowAirCompleted() {
            if (constants.verboseMode) console.debug("BlowAir handler entry: ", fullStatus)
            blowAirCompleted = true
            if (fullStatus > statusEnum['Blow1']) {
                fullStatus = statusEnum['Final']
            }
            else {
                fullStatus = statusEnum['Blow1']
            }
            if (constants.verboseMode) console.debug("BlowAir handler exit: ", fullStatus)
            setStatusBar()
        }
    }

    /* Perf info */
    SystemInfo {
        id: systemInfo
    }

    /* Size management */
    Constants {
        id: constants
    }

    /* Load custom font */
    FontLoader {
        id: myFont
        source: "/assets/Font/NorwesterPro-Rounded.otf"
    }

    /* video loader */
    Loader {
        id: videoLoader
        source: "/qml/VideoMenu.qml"
        active: false
        z: 1
    }

    /* Bottom menu except video part */
    Loader {
        id: bottomMenuLoader
        source: "/qml/BottomMenu.qml"
        active: true
        z: 1
    }

    /* Define a full window mouse area to mask all event during demo mode */
    MouseArea {
        id: hideAllMouseEvents
        anchors.fill: parent
        visible: constants.selfDemoMode
        z: 100
    }

    /* Quit button that can be activated even in self demo mode */
    Image {
        id: menu
        anchors { left: parent.left; top: parent.top }
        anchors.topMargin: constants.getPixelSize(6)
        anchors.leftMargin: constants.getPixelSize(20)
        z: hideAllMouseEvents.z + 100 /* over the mouse area to mask other user interaction */
        source: "/assets/HeartRate_%1/Icon_back_to_main_menu.png".arg(constants.assetDir)

        Text {
            id: menuText
            anchors { left: parent.right; verticalCenter: parent.verticalCenter }
            anchors.leftMargin: constants.getPixelSize(10)
            text: qsTr("quit")
            color: constants.blueColor
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(18)
            font.family: myFont.name
        }

        MouseArea {
            id: quitApp
            anchors.fill: parent
            anchors.margins: constants.getPixelSize(-10)
            onPressed: {
                menuText.color = constants.highlightedBlueColor
            }
            onReleased: {
                Qt.quit()
            }
            onCanceled: {
                menuText.color = constants.blueColor
            }
        }
    }

    /* Self demo mode indicator */
    CustomButton {
        id: demoButton
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
        anchors.topMargin: constants.getPixelSize(3)
        z: hideAllMouseEvents.z + 100 /* over the mouse area to mask other user interaction */
        text: qsTr("self demo mode off")
        onCheckedChanged: {
            if (constants.selfDemoMode) {
                constants.selfDemoMode = false
                demoButton.text = qsTr("self demo mode off")
                stackView.pop(null)
                stackView.state = 'Startup'
                stackView.push("/qml/Startup.qml")
            }
            else {
                constants.selfDemoMode = true
                demoButton.text = qsTr("self demo mode on")
                stackView.pop(null)
                stackView.state = 'Startup'
                stackView.push("/qml/Startup.qml", {"demoMode": "true"})
            }
        }
    }

    /* Stackview for all screens */
    StackView {
        id: stackView
        anchors.fill: parent
        focus: true
        initialItem: LoadingPage {
        }
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
            }
        }
        popEnter: pushEnter
        popExit: pushExit

        /* state machine for screens managing bottom button status */
        states: [
            State {
                name: "Startup"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: false
                    nextTextColor: constants.highlightedBlueColor
                }
                PropertyChanges {
                    target: statusBar
                    visible: false
                }
                StateChangeScript {
                    name: "resetStatus"
                    script: {
                        fullStatus = statusEnum['Start']
                        setStatusBar()
                    }
                }
            },
            State {
                name: "Help"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: true
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: false
                    nextTextColor: helpCompleted ? constants.highlightedBlueColor : constants.blueColor
                }
                PropertyChanges {
                    target: statusBar
                    visible: false
                }
            },
            State {
                name: "Aed"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: true
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: false
                    nextTextColor: "transparent"
                }
                PropertyChanges {
                    target: statusBar
                    visible: false
                }
            },
            State {
                name: "HeartRate"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: true
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: true
                    nextTextColor: heartRateCompleted ? constants.highlightedBlueColor : constants.blueColor
                }
                PropertyChanges {
                    target: statusBar
                    visible: true
                }
            },
            State {
                name: "SecureAirways"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: true
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: true
                    nextTextColor: secureAirwaysCompleted ? constants.highlightedBlueColor : constants.blueColor
                }
                PropertyChanges {
                    target: statusBar
                    visible: true
                }
            },
            State {
                name: "BlowAir"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: true
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: true
                    nextTextColor: blowAirCompleted ? constants.highlightedBlueColor : constants.blueColor
                }
                PropertyChanges {
                    target: statusBar
                    visible: true
                }
            },
            State {
                name: "Final"
                PropertyChanges {
                    target: bottomMenu
                    aedVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    videoVisible: false
                }
                PropertyChanges {
                    target: bottomMenu
                    restartEnabled: false
                    nextTextColor: "transparent"
                }
                PropertyChanges {
                    target: statusBar
                    visible: false
                }
            }
        ]
    }

    /* background */
    Background {
        id: background
        anchors.fill: parent
        z: -2
    }

    /* top and bottom menu */
    TopMenu {
        id: topMenu
        z: 2
    }

    BottomMenu {
        id: bottomMenu
    }

    /* progress status bar */
    Image {
        id: statusBar
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        anchors.bottomMargin: parent.height / 20
        source: "/assets/BlowAir_%1/button_progress_bar_1.png".arg(constants.assetDir)
        z: 2
    }
}
