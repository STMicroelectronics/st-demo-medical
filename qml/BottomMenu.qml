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
    anchors.fill: parent

    /* option for menu items visibility */
    property bool aedVisible: false
    property bool videoVisible: true
    property alias restartEnabled: restartMouseArea.enabled
    property alias nextTextColor: nextText.color

    /* Bottom menu and buttons */
    Image {
        id: bottomMenu
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        source: "/assets/HeartRate_%1/button_menu.png".arg(constants.assetDir)
        fillMode: Image.Stretch
        width: parent.width
        z: 2

        /* video info */
        Image {
            id: video
            anchors { left: parent.left; bottom: parent.bottom }
            anchors.bottomMargin: constants.getPixelSize(8)
            anchors.leftMargin: constants.getPixelSize(30)
            source: "/assets/HeartRate_%1/play_video_icon.png".arg(constants.assetDir)
            visible: videoVisible

            MouseArea {
                anchors.fill: parent
                anchors.margins: constants.getPixelSize(-10)
                onClicked: {
                    bottomMenuLoader.active = false
                    /* Unload current view to free memory */
                    if (constants.verboseMode) console.debug("Stack depth is ", stackView.depth)
                    if (constants.verboseMode) console.debug("Unload current view: ", stackView.state)
                    if (stackView.depth >= 2) {
                        stackView.pop()
                        if (constants.verboseMode) console.debug("Current view unloaded. View state is ", stackView.state)
                        if (constants.verboseMode) console.debug("Stack depth is ", stackView.depth)
                    }
                    /* Load video view */
                    if (stackView.state === 'HeartRate') {
                        /* Load video view */
                        videoLoader.setSource("/qml/VideoMenu.qml", {"sourceFile": "heart_%1.mp4".arg(constants.assetVideoDir)});
                    }
                    else if (stackView.state === 'BlowAir' || stackView.state === 'SecureAirways') {
                        videoLoader.setSource("/qml/VideoMenu.qml", {"sourceFile": "air_%1.mp4".arg(constants.assetVideoDir)});
                    }
                    if (constants.verboseMode) console.debug("View state is ", stackView.state)
                    if (constants.verboseMode) console.debug("Stack depth is ", stackView.depth)
                    videoLoader.active = true
                    statusBar.visible = false
                }
            }

            Text {
                id: videoText
                anchors { left: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: constants.getPixelSize(10)
                text: qsTr("watch instructional video")
                color: constants.highlightedBlueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(15)
                font.family: myFont.name
            }
        }

        /* aed info instead of video */
        Image {
            id: aedMenu
            anchors { left: parent.left; bottom: parent.bottom }
            anchors.bottomMargin: constants.getPixelSize(8)
            anchors.leftMargin: constants.getPixelSize(30)
            source: "/assets/BlowAir_%1/icon_AED_normal.png".arg(constants.assetDir)
            visible: aedVisible

            MouseArea {
                anchors.fill: parent
                anchors.margins: constants.getPixelSize(-10)
                onClicked: {
                    if (stackView.state === 'Help') {
                        stackView.state = 'Aed'
                        stackView.pop()
                        stackView.push("/qml/Aed.qml")
                    }
                }
            }

            Text {
                id: aedText
                anchors { left: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: constants.getPixelSize(10)
                text: qsTr("what is an 'aed'?")
                color: constants.highlightedBlueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(15)
                font.family: myFont.name
            }
        }

        RowLayout {
            anchors { right: parent.right; bottom: parent.bottom }
            anchors.bottomMargin: constants.getPixelSize(8)
            anchors.rightMargin: constants.getPixelSize(20)
            spacing: constants.getPixelSize(60)
            /* Today no pop and previous button visible to make user story simpler */
            Text {
                id: restartText
                text: "<< restart"
                color: constants.blueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(18)
                font.family: myFont.name
                visible: restartMouseArea.enabled

                MouseArea {
                    id: restartMouseArea
                    anchors.fill: parent
                    anchors.margins: constants.getPixelSize(-15)
                    enabled: false
                    onClicked: {
                        stackView.pop(null)
                        stackView.state = 'Startup'
                        stackView.push("/qml/Startup.qml")
                    }
                }
            }
            Text {
                id: nextText
                text: "next >"
                color: constants.highlightedBlueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(18)
                font.family: myFont.name
                visible: true

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: constants.getPixelSize(-15)
                    onClicked: {
                        /* State update to be done before for bottom buttons updates */
                        /* As "previous" button is no more activated, we can release ressource and pop before push */
                        if (constants.verboseMode && (stackView.depth > 2)) console.debug("Stackview depth", stackView.depth)
                        /* First pass */
                        if (fullStatus < statusEnum['Blow1']) {
                            if (stackView.state === 'Startup') {
                                stackView.state = 'Help'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/Help.qml")
                            }
                            else if (stackView.state === 'Help') {
                                stackView.state = 'HeartRate'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/HeartRate.qml")
                            }
                            else if (stackView.state === 'HeartRate') {
                                stackView.state = 'SecureAirways'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/SecureAirways.qml")
                            }
                            else if (stackView.state === 'SecureAirways') {
                                stackView.state = 'BlowAir'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/BlowAir.qml")
                            }
                            /* restart from beginning */
                            else {
                                stackView.pop(null)
                                stackView.state = 'Startup'
                                stackView.push("/qml/Startup.qml")
                            }
                        }
                        /* Second pass: no startup, no help */
                        else if (fullStatus < statusEnum['Blow2']) {
                            if (stackView.state === 'HeartRate') {
                                stackView.state = 'BlowAir'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/BlowAir.qml")
                            }
                            else if (stackView.state === 'BlowAir') {
                                stackView.state = 'HeartRate'
                                if (stackView.depth >= 2) stackView.pop()
                                stackView.push("/qml/HeartRate.qml")
                            }
                        }
                        /* Go to Final */
                        else if (fullStatus >= statusEnum['Blow2']) {
                            stackView.state = 'Final'
                            if (stackView.depth >= 2) stackView.pop()
                            stackView.push("/qml/Final.qml")
                        }
                        /* default, should not happen */
                        else {
                            stackView.pop(null)
                            stackView.state = 'Startup'
                            stackView.push("/qml/Startup.qml")
                        }
                    }
                }
            }
        }
    }

}
