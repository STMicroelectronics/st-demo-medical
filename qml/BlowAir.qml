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
    property int blowCount: 0
    property int blowCountMax: 2

    /* cursor motion */
    property real targetPerMinute: 30 /* how long to blow */
    property real minValue: -220
    property real maxValue: 40
    property real midValue: minValue + (maxValue - minValue)/2
    property real startValue: minValue
    property real sweepValue: 0
    property real timerInverval: 50 /* cursor speed finess */
    property bool moveCursor: false
    property bool deflate: false
    property real deflateFactor: 4 /* how fast deflate occurs compare to inflate speed */

    /* step colors */
    readonly property color color16: "#ff8d0f17"
    readonly property color color1: "#ff1f496d"

    /* gradient color is overlay color blent with an alpha value */
    property color gradColor: Qt.rgba(circleOverlay.color.r, circleOverlay.color.g,
                                      circleOverlay.color.b, circleOverlay.color.a * 0.5)

    /* demo mode */
    property bool demoMode: false
    property bool demoModeVideo: false

    /* completion signal */
    property bool signalCompletionSent: false
    signal signalBlowAirCompleted()

    /* action when mouseArea is pressed */
    function mouseAreaPressed() {
        /* red lungs */
        lungs.source = "/assets/BlowAir_%1/lungs.png".arg(constants.assetDir)

        /* mask circle around mouth */
        circleOverlayMouth.visible = false

        /* begin normal flow */
        if (root.state == 'start') {
            root.state = 'blow1'
        }

        /* reset cursor position and start animation*/
        startValue = minValue
        moveCursor = true
        deflate = false
        lungDeflate.stop()
        lungInflate.start()
        cursorAnim.start()
        pulseAnim.start()
        colorAnim.restart()

        if (root.state == 'blow1') {
            root.state = 'blow2'
            if (blowCount < blowCountMax) blowCount ++
        }
        else if (root.state == 'blow1_final') {
            root.state = 'blow2_final'
        }
    }

    /* action when mouseArea is released */
    function mouseAreaReleased() {

        /* redraw circle around mouth */
        circleOverlayMouth.visible = true

        moveCursor = true
        deflate = true
        lungDeflate.start()
        lungInflate.stop()
        pulseAnim.stop()

        /* Go to final state when a few count, but still do animation */
        if (root.state == 'blow2') {
            if (blowCount >= blowCountMax) {
                root.state = 'blow1_final'
                if (!signalCompletionSent)
                {
                    signalBlowAirCompleted()
                    signalCompletionSent = true
                }
            }
            else {
                root.state = 'blow1'
            }
        }
        else if (root.state == 'blow2_final') {
                root.state = 'blow1_final'
        }
    }

    /* delay function */
    function delay(delayTime, cb) {
        delayTimer.interval = delayTime;
        delayTimer.repeat = false;
        delayTimer.triggered.connect(cb);
        delayTimer.start();
    }
    function delay2(delayTime, cb) {
        delayTimer2.interval = delayTime;
        delayTimer2.repeat = false;
        delayTimer2.triggered.connect(cb);
        delayTimer2.start();
    }

    Component.onCompleted:
    {
        /* On each screen push, we reset internal completion status */
        blowAirCompleted = false

        /* Internal state machine */
        if (root.state == '') {root.state = 'start'}
    }

    /* state machine for Blow Air */
    states: [
        State {
            name: "start"
            PropertyChanges {
                target: circleOverlay
                opacity: 0
            }
            PropertyChanges {
                target: circleOverlay
                color: color1
            }
        },
        State {
            name: "blow1"
            PropertyChanges {
                target: circleOverlay
                opacity: 0.5
            }
            PropertyChanges {
                target: circleOverlay
                color: color1
            }
        },
        State {
            name: "blow2"
            PropertyChanges {
                target: circleOverlay
                opacity: 0.5
            }
        },
        /* final stage, but we can continue blowing */
        State {
            name: "blow1_final"
            PropertyChanges {
                target: circleOverlay
                opacity: 0.5
            }
            PropertyChanges {
                target: circleOverlay
                color: color1
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
            }
        },
        State {
            name: "blow2_final"
            PropertyChanges {
                target: circleOverlay
                opacity: 0.5
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
            }
        }
    ]

    /* smooth transition between mouth and lungs rings */
    transitions: [
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation {
                targets: [circleOverlay]
                properties : "opacity"
                duration: 300
            }
        }
    ]

    /* Specific timer for delay purpose */
    Timer
    {
        id: delayTimer
    }
    /* When two delays used inside same function */
    Timer
    {
        id: delayTimer2
    }

    /* demo mode timer for video */
    Timer {
        id: demoTimerVideo
        running: demoModeVideo
        interval: 1200
        repeat: false
        onTriggered: {
            /* play video first */
            bottomMenuLoader.active = false
            videoLoader.setSource("/qml/VideoMenu.qml", {"sourceFile": "air_%1.mp4".arg(constants.assetVideoDir)});
            videoLoader.active = true
            statusBar.visible = false
            /* after a delay to be sure video is ended, activate blowAir demo mode */
            delay(4000, function() {
                /* start blowAir demo */
                demoTimer.start()
            })
        }
    }

    /* demo mode timer */
    Timer {
        id: demoTimer
        running: demoMode
        interval: 3000
        repeat: true
        onTriggered: {
            if (constants.verboseMode && (stackView.depth > 2)) console.debug("Stackview depth", stackView.depth)
            /* simulate mouse pressed and released event */
            if (constants.verboseMode) console.debug("mouseAreaPressed")
            mouseAreaPressed()
            delay(2200, function() {
                if (constants.verboseMode) console.debug("Delayed mouseAreaReleased")
                mouseAreaReleased()
            })

            /* change screen when reaching max count */
            if (blowCount == blowCountMax) {
                demoTimer.stop()
                delay2(6000, function() {
                    if (fullStatus >= statusEnum['Blow2']) {
                        if (constants.verboseMode) console.debug("Demo goes to final")
                        stackView.state = 'Final'
                        if (stackView.depth >= 2) stackView.pop()
                        stackView.push("/qml/Final.qml", {"demoMode": "true"})
                    }
                    else {
                        if (constants.verboseMode) console.debug("Demo goes to second pass")
                        stackView.state = 'HeartRate'
                        if (stackView.depth >= 2) stackView.pop()
                        stackView.push("/qml/HeartRate.qml", {"demoMode": "true"})
                    }
                })
            }
        }
    }

    /* Timer to move gauge cursor */
    Timer {
        id: cursorTimer
        running: true
        interval: timerInverval
        repeat: true

        onTriggered:
        {
            cursorAnim.start()
            if (moveCursor) {
                /* default sweep depends only on targetPerMinute and range */
                sweepValue = ((maxValue - midValue) * (timerInverval / 1000)) / (60 / targetPerMinute)
                /* In case cursor has to go back. 4 times faster than inflate */
                if (deflate) {
                    sweepValue = - sweepValue * deflateFactor
                }
                //console.log("before: " + startValue,  sweepValue, minValue, maxValue)
                if (startValue < minValue) {
                    startValue = minValue
                    sweepValue = 0
                }
                else if (startValue + sweepValue >= maxValue) {
                    startValue = maxValue
                }
                else if (startValue + sweepValue <= maxValue) {
                    startValue = startValue + sweepValue
                }
                else if (startValue >= maxValue) {
                    startValue = minValue /* restart plot */
                    sweepValue = 0
                }

                /* In case backward, recheck min limit */
                if (startValue < minValue) {
                    startValue = minValue
                }
                //console.log("after: " + startValue,  sweepValue)
            }
            cursorAnim.stop()
        }
    }

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
            text: qsTr("breath air into")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
        Text {
            id: action
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("the mouth")
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(30)
            font.family: myFont.name
        }
    }

    /* Scenario info */
    Text {
        id: whatToDo
        anchors { horizontalCenter:  parent.horizontalCenter; bottom: parent.bottom }
        anchors.bottomMargin: root.height / 5
        text: qsTr("keep finger pressed on mouth to blow air into the lungs")
        color: "white"
        fontSizeMode: Text.FixedSize
        font.pointSize: constants.getPixelSize(18)
        font.family: myFont.name
        z: 2
    }

    /* Man with graphical effects */
    ManEffects {
        id: man
        anchors.fill: parent

        /* Rectangle for mouse area around mouth */
        Rectangle {
            id: mouth
            width: lungs.width * 1.5
            height: lungs.height * 1.5
            color: "transparent"
            anchors { verticalCenter: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.verticalCenterOffset: - constants.manHeight * 0.75 /* mouth position from bottom */
            radius: width/2

            /* rings with color around mouth */
            Image {
                id: circleMouth
                anchors.centerIn: parent
                anchors.fill: parent
                source: "/assets/BlowAir_%1/mouth_gradient_attention.png".arg(constants.assetDir)
                antialiasing: true
                visible: false
            }

            ColorOverlay {
                id: circleOverlayMouth
                anchors.fill: circleMouth
                source: circleMouth
                color: "white"
                antialiasing: true
            }

            MouseArea {
                id: pressArea
                anchors.centerIn: parent
                width: mouth.width / 2
                height: mouth.height / 2
                onPressed: {
                    mouseAreaPressed()
                }
                onReleased: {
                    mouseAreaReleased()
                }
            }
        }

        Rectangle {
            id: lungsArea
            /* relative position versus man body, independant of man resolution */
            anchors { verticalCenter: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.verticalCenterOffset: - constants.manHeight * 0.60 /* lungs position from bottom */
            anchors.horizontalCenterOffset: constants.getPixelSize(2) /* slight center correction */
            width: constants.manWidth * 1.2
            height: constants.manWidth * 1.2
            radius: width/2
            color: "transparent"

            /* blow air animation */
            SequentialAnimation on scale {
                id: lungInflate
                running: false
                NumberAnimation {
                    from: 1
                    to: 1.15
                    duration: 2 * (60000)/targetPerMinute
                    loops: 1
                }
            }
            /* actually masked by opacity propery change */
            SequentialAnimation on scale {
                id: lungDeflate
                running: false
                NumberAnimation {
                    from: lungsArea.scale
                    to: 1
                    duration: (2 * (60000)/targetPerMinute) / deflateFactor
                    loops: 1
                }
            }

            Image {
                id: lungs
                anchors.centerIn: parent
                source: "/assets/BlowAir_%1/lungs_grey.png".arg(constants.assetDir)
                z: 2
            }

            /* rings with color around lungs */
            Image {
                id: circle
                anchors.centerIn: parent
                anchors.fill: parent
                source: "/assets/HeartRate_%1/svg_rings.svg".arg(constants.assetDir)
                antialiasing: true
                visible: false
            }

            ColorOverlay {
                id: circleOverlay
                anchors.fill: circle
                source: circle
                color: "blue"
                antialiasing: true
                opacity: 0 /* for starting point */
                /* Animation on overlay color depending on cursor position */
                SequentialAnimation {
                    id: colorAnim
                    running: false
                    /* one way */
                    PropertyAnimation  { target: circleOverlay; property: "color"; from: color1; to: color16;
                                         duration: 1000 * 2 * (60 / targetPerMinute) }
                    /* and return */
                    PropertyAnimation  { target: circleOverlay; property: "color"; from: color16; to: color1;
                                         duration: (1000 * 2 * (60 / targetPerMinute)) / deflateFactor }

                }
            }

            RadialGradient {
                id: gradLungs
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: gradColor}
                    GradientStop { position: 0.5; color: "transparent" }
                }
            }
        }
    }

    /* Blow rate gauge */
    Image {
        id: gauge
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.rightMargin: constants.getPixelSize(50)
        anchors.verticalCenterOffset: constants.getPixelSize(-60)
        source: "/assets/BlowAir_%1/Air_blow_gauge_bg.png".arg(constants.assetDir)

        /* moving cursor */
        Image {
            id: cursor
            source: "/assets/HeartRate_%1/gauge_dot.png".arg(constants.assetDir)
        }

        Path {
            id: gaugePath
            startX: 0; startY: 0
            PathAngleArc {
                id: pathArcId
                centerX: gauge.width/2
                centerY: gauge.height/2 + gauge.height/40 /* arc y center is not in the middle of the image */
                radiusX: gauge.width/2 - gauge.width/11
                radiusY: gauge.height/2 - gauge.height/11
                startAngle: startValue
                sweepAngle: sweepValue
            }
        }

        PathAnimation {
            id: cursorAnim
            target: cursor
            running: true
            duration: 500
            loops: 1
            path: gaugePath
            anchorPoint: Qt.point(cursor.width/2, cursor.height/2)
        }

        /* blow info */
        ColumnLayout {
            id: blowInfo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: constants.getPixelSize(20)
            Text {
                id: blowRate
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("blow air")
                color: constants.highlightedBlueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(13)
                font.family: myFont.name
            }
            Text {
                id: blowFreq
                Layout.alignment: Qt.AlignHCenter
                text: blowCount + "/" + blowCountMax
                color: "white"
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(40)
                font.family: myFont.name
            }
            /* blow air animated image */
            Image {
                id: pulse
                source: "/assets/BlowAir_%1/BlowAir/BlowAir_".arg(constants.assetDir)+idx+".png"
                Layout.alignment: Qt.AlignHCenter
                property int idx:1
                /* Animation trick to avoid gif uggly rendering. 20 fps movement */
                NumberAnimation on idx {
                    id: pulseAnim
                    running: false
                    from: 1; to: 20; duration: 1000; loops: -1
                }
            }
        }
    }

}
