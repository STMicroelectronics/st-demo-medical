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

    /* slider arc path parameter. Empiric value */
    property real sweepValueSliderMax: -35.85

    /* Particular point in slider: start, middle, final. Get from png files */
    property real startX: (constants.screenWidth === 1920) ? 656 : 350
    property real startY: (constants.screenWidth === 1920) ? 108 : 58
    property real finalX: (constants.screenWidth === 1920) ? 44  : 24
    property real finalY: startY
    property real radius: (constants.screenWidth === 1920) ? 1082 : 602
    property real arcCenterY: (constants.screenHeight < 1080) ? 600 : 1080 /* arc center is fixed with radius */

    /* Relative slider button position inside slider image */
    property real sliderButtonPositionX: startX
    property real sliderButtonPositionY: startY
    /* Percentage of X button progress between startX and finalX */
    property real sliderButtonPercent: (sliderButtonPositionX - finalX) / (startX - finalX)
    /* Relation between percentage progress and sweep angle value: from sweepValueSliderMax (start) to 0 (final) */
    property real sliderButtonSweepValue: sweepValueSliderMax * sliderButtonPercent

    /* demo mode */
    property bool demoMode: false

    /* blend effect */
    property bool blendEffect: constants.blendEffect

    /* completion signal */
    signal signalSecureAirwaysCompleted()

    Component.onCompleted:
    {
        /* On each screen push, we reset internal completion status */
        secureAirwaysCompleted = false

        /* Internal state machine */
        if (root.state == '') {root.state = 'secure1'}
    }

    /* state machine for SecureAirways */
    states: [
        State {
            name: "secure1"
        },

        State {
            name: "secure2"
            PropertyChanges {
                target: sliderArrow
                source: "/assets/BlowAir_%1/Tilt_head_button_done_icon.png".arg(constants.assetDir)
            }
            PropertyChanges {
                target: secure2Info
                visible: true
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
            }
        }
    ]

    /* smooth text transition */
    transitions: [
        Transition {
            from: "secure1"
            to: "secure2"
            PropertyAnimation {
                targets: [step1]
                properties : "opacity"
                from: 1
                to: 0
                duration: 300
            }
            PropertyAnimation {
                targets: [secure2Info]
                properties : "opacity"
                from: 0
                to: 1
                duration: 500
            }
        }
    ]

    /* Blow directives */
    ColumnLayout {
        id: directives
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        anchors.leftMargin: constants.getPixelSize(30)
        anchors.verticalCenterOffset: constants.getPixelSize(-60)

        Text {
            id: info1
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("performing")
            color: constants.highlightedBlueColor
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
        Text {
            id: info2
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("mouth-to-mouth")
            color: constants.highlightedBlueColor
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
        Text {
            id: step
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: constants.getPixelSize(30)
            text: qsTr("step ")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
            Text {
                id: step1
                anchors { left: parent.right } // to avoid layout recomputation
                text: qsTr("1")
                color: "white"
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(30)
                font.family: myFont.name
                opacity: 1
            }
            Text {
                id: step2
                anchors { left: parent.right } // to avoid layout recomputation
                text: qsTr("2")
                color: "white"
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(30)
                font.family: myFont.name
                opacity: !step1.opacity
            }
        }
        Text {
            id: action
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("secure airways")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
    }

    /* glow */
    Image {
        id: glow
        anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
        source: "/assets/HeartRate_%1/main_overlay_glow.png".arg(constants.assetDir)
        //smooth: blendEffect
        //visible: !blendEffect
    }

    /* face with effects */
    Rectangle {
        id: faceRectangle
        anchors.fill: parent
        color: "transparent"
        //smooth: blendEffect
        //visible: !blendEffect
        Image {
            id: face
            anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
            anchors.bottomMargin: height / 7
            source: "/assets/BlowAir_%1/face_big.png".arg(constants.assetDir)
            /* 0 is start position, sweepValueSliderMax is final position */
            rotation: sweepValueSliderMax - sliderButtonSweepValue
        }
    }

    /*Blend {
        anchors.fill: faceRectangle
        source: faceRectangle
        foregroundSource: glow
        mode: "screen"
        enabled: blendEffect
    }*/

    /* slider */
    Image {
        id: slider
        anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
        /* cannot anchor slider directly to face child object */
        anchors.bottomMargin: height / 7 + constants.getPixelSize(20) + face.height
        source: "/assets/BlowAir_%1/Tilt_head_slider_bg.png".arg(constants.assetDir)

        Image {
            id: sliderButton
            source: "/assets/BlowAir_%1/Tilt_head_button_normal.png".arg(constants.assetDir)
            /* relative position of button center */
            x: sliderButtonPositionX - (sliderButton.width / 2)
            y: sliderButtonPositionY - (sliderButton.height / 2)

            Image {
                id: sliderArrow
                anchors { centerIn: parent }
                source: "/assets/BlowAir_%1/Tilt_head_button_arrow_icon.png".arg(constants.assetDir)
            }

            Image {
                id: sliderButtonGlow
                anchors { centerIn: parent }
                source: "/assets/BlowAir_%1/Tilt_head_button_glow.png".arg(constants.assetDir)
                z: sliderButton.z - 1
            }
        }

        MouseArea {
            id: sliderMotion
            anchors.fill: slider
            onMouseXChanged: {
                if (root.state != 'secure2') {
                    /* mouseX is relative to MouseArea, ie slider */
                    /* limit on left side */
                    if (mouseX <= finalX) {
                        sliderButtonPositionX= finalX
                        /* end of move */
                        root.state = 'secure2'
                        signalSecureAirwaysCompleted()
                    }
                    /* limit on right side */
                    else if (mouseX >= startX) {
                        sliderButtonPositionX = startX
                    }
                    else {
                        sliderButtonPositionX = mouseX
                    }
                    //console.log(sliderButtonPositionX)
                    //console.log(sliderButtonSweepValue)
                    var point = sliderPath.pointAtPercent(sliderButtonPercent);
                    //console.log(point.y) /* min and max should be symetric versus arc parameters */
                    sliderButton.y = point.y
                }
            }
        }
    }

    /* slider button path */
    Path {
        id: sliderPath
        startX: 0; startY: 0
        PathAngleArc {
            id: sliderArcId
            /* slider horizontal centered */
            centerX: root.width / 2
            centerY: arcCenterY
            radiusX: radius
            radiusY: radius
            /* Must be symetric */
            startAngle: sweepValueSliderMax * 2
            sweepAngle: sweepValueSliderMax
        }
    }

    /* Or text in secure2 state */
    ColumnLayout {
        id: secure2Info
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.rightMargin: constants.getPixelSize(30)
        anchors.verticalCenterOffset: constants.getPixelSize(-60)
        visible: false

        /* pinch nose animated image */
        Image {
            id: pinchNose
            source: "/assets/BlowAir_%1/Pinsh_nose_".arg(constants.assetDir)+idx+".png"
            Layout.alignment: Qt.AlignHCenter
            property int idx:1
            NumberAnimation on idx { from: 1; to: 8; duration: 1000; loops: -1}
        }

        Text {
            id: secureInfo1
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: constants.getPixelSize(20)
            text: qsTr("pinch nose while performing")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(18)
            font.family: myFont.name
        }
        Text {
            id: secureInfo2
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("mouth-to-mouth")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
    }

}
