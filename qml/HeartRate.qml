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
import Qt5Compat.GraphicalEffects
import QtMultimedia

Item {
    id: root
    property bool beatValid: false
    property bool reverse: false
    property real reverseFactor: 5
    property int initialBeatValue: 20 + rnd10()
    property int beatValue: (beatValid) ? initialBeatValue : 0
    property int initialChestPressedCount: 10
    property int chestPressedCount: initialChestPressedCount

    /* chest compression parameters */
    property real timePressedPrevious: 0
    property real timePressed: 0
    property real targetPerMinute: 65
    property real maxTime: 60 / (targetPerMinute)
    property real minTime: 60 / (targetPerMinute)

    /* cursor motion */
    property real minValue: -220
    property real maxValue: 40
    property real midValue: minValue + (maxValue - minValue)/2
    property real startValue: minValue
    property real sweepValue: 0
    property real checkTimerInverval: 50 /* cursor speed finess */

    /* step colors */
    readonly property color color8: "#cc11bc00"
    readonly property color color1: "#ccff0000"

    /* gradient color is overlay color blent with an alpha value */
    property color gradColor: Qt.rgba(circleOverlay.color.r, circleOverlay.color.g,
                                      circleOverlay.color.b, circleOverlay.color.a * 0.8)

    /* demo mode */
    property bool demoMode: false
    property bool demoModeVideo: false

    /* completion signal */
    property bool signalCompletionSent: false
    signal signalHeartRateCompleted()

    /* returns system time */
    function reportTime() {
        var myTime = Date.now()/1000
        //myTime = Math.round(myTime * 100) / 100
        return myTime
    }

    /* Returns random number between 0 and 9 */
    function rnd10() {
         return Math.floor(Math.random() * 10)
    }

    /* action done when press on chest area */
    function mouseAreaPressed() {
        /* First click actions */
        if (root.state === 'entry') {
            root.state = 'start'
            /* Only restart heat beat animation when changing particular states. QML Transition usage not usable in that case */
            heartBeat.restart()
            if (constants.verboseMode) console.log("(start) beatValid="+beatValid+", beatValue="+beatValue+", duration="+2*heartBeatAnim1.duration)
        }

        /* time reports */
        if (chestPressedCount === initialChestPressedCount) {
            timePressedPrevious = reportTime()
        }
        else {
            timePressed = reportTime()
            timePressedPrevious = timePressed
        }

        /* compression number and state machine management */
        if (chestPressedCount > 0) {
            chestPressedCount--
        }

        /* check if final state */
        if (chestPressedCount ==  0) {
            /* end of compression */
            root.state = 'final'
            if (!signalCompletionSent)
            {
                heartBeat.restart()
                if (constants.verboseMode) console.log("(final) beatValid="+beatValid+", beatValue="+beatValue+", duration="+2*heartBeatAnim1.duration)
                signalHeartRateCompleted()
                signalCompletionSent = true
            }
        }

        /* reset cursor position */
        startValue = minValue
        reverse = false

        /* State machine after start */
        if (root.state == 'start') {
            root.state = 'continue'
        }
        else if (root.state == 'continue' && chestPressedCount <= 1/3 * initialChestPressedCount) {
            root.state = 'keep'
            heartBeat.restart()
            if (constants.verboseMode) console.log("(keep) beatValid="+beatValid+", beatValue="+beatValue+", duration="+2*heartBeatAnim1.duration)
        }

        /* Restart animations to get value update */
        colorAnim.restart()
        ringsAnimReverse.stop()
        ringsAnim.restart()
        colorAnim.start()
        colorAnimReverse.stop()
    }

    /* action when mouseArea is released */
    function mouseAreaReleased() {
        /* reverse animations are done when reaching limit only */
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
        heartRateCompleted = false

        /* Init state machine */
        if (root.state == '') {root.state = 'entry'}
    }

    /* state machine for Chest Comppression */
    states: [
        State {
            name: "entry"
            PropertyChanges {
                target: whatToDo
                visible: true
            }
            PropertyChanges {
                target: msg
                visible: true
            }
            PropertyChanges {
                target: info
                visible: true
            }
            PropertyChanges {
                target: nb
                visible: true
            }
            PropertyChanges {
                target: root
                beatValid: false
            }
        },
        State {
            name: "start"
            PropertyChanges {
                target: whatToDo
                visible: false
            }
            PropertyChanges {
                target: msg
                visible: true
            }
            PropertyChanges {
                target: info
                visible: true
            }
            PropertyChanges {
                target: nb
                visible: true
            }
            PropertyChanges {
                target: root
                beatValid: true
            }
        },
        State {
            name: "continue"
            PropertyChanges {
                target: msg
                text: qsTr("keep going")
            }
            PropertyChanges {
                target: root
                beatValid: true
            }
        },
        State {
            name: "keep"
            PropertyChanges {
                target: msg
                text: qsTr("keep it up")
            }
            PropertyChanges {
                target: root
                initialBeatValue: 50 + rnd10()
            }
            PropertyChanges {
                target: root
                beatValid: true
            }
        },
        State {
            name: "final"
            PropertyChanges {
                target: msg
                text: qsTr("completed")
            }
            PropertyChanges {
                target: root
                initialBeatValue: 70 + rnd10()
            }
            PropertyChanges {
                target: root
                beatValid: true
            }
            PropertyChanges {
                target: bottomMenu
                nextTextColor: constants.highlightedBlueColor
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
            videoLoader.setSource("/qml/VideoMenu.qml", {"sourceFile": "heart_%1.mp4".arg(constants.assetVideoDir)});
            videoLoader.active = true
            statusBar.visible = false
            /* after a delay to be sure video is ended, activate heartRate demo mode */
            delay(5500, function() {
                /* start heartRate demo */
                demoTimer.start()
            })
        }
    }

    /* demo mode timer */
    Timer {
        id: demoTimer
        running: demoMode
        interval: 1200
        repeat: true
        onTriggered: {
            /* simulate tap event */
            mouseAreaPressed()
            delay(2200, function() {
                mouseAreaReleased()
            })
            /* change screen when reaching 0 count */
            if (chestPressedCount == 0) {
                demoTimer.stop()
                delay2(3000, function() {
                    stackView.state = 'BlowAir'
                    if (stackView.depth >= 2) stackView.pop()
                    /* Launch blowAir demo. With or without video depending on state */
                    if (fullStatus >= statusEnum['Heart2']) {
                        stackView.push("/qml/BlowAir.qml", {"demoMode": "true"})
                    }
                    else {
                        stackView.push("/qml/BlowAir.qml", {"demoModeVideo": "true"})
                    }
                })
            }
        }
    }

    /* Timer to check chest compression action and trigger state machine */
    Timer {
        id: checkTimer
        running: (chestPressedCount != initialChestPressedCount) ? true: false
        interval: checkTimerInverval
        repeat: true

        onTriggered:
        {
            cursorAnim.start()
            /* default sweep depends only on targetPerMinute and range */
            sweepValue = ((maxValue - midValue) * (checkTimerInverval / 1000)) / (60 / targetPerMinute)
            /* move backward after tap release */
            if (reverse) {
                sweepValue = - reverseFactor * sweepValue /* ball goes back to start point very fast */
            }
            //console.log("before: " + startValue,  sweepValue, minValue, maxValue)
            if (startValue < minValue) {
                startValue = minValue
                sweepValue = 0
            }
            else if (startValue + sweepValue >= maxValue) {
                startValue = maxValue
                /* do reverse animations */
                reverse = true
                ringsAnimReverse.start()
                ringsAnim.stop()
                colorAnimReverse.start()
                colorAnim.stop()
            }
            else if (startValue + sweepValue <= maxValue) {
                startValue = startValue + sweepValue
            }
            else if (startValue >= maxValue) {
                startValue = minValue /* restart plot */
                sweepValue = 0
            }

            /* In case reverse, recheck min limit */
            if (startValue < minValue) {
                startValue = minValue
            }
            //console.log("after: " + startValue,  sweepValue)
            cursorAnim.stop()
        }
    }

    /* Compression info */
    ColumnLayout {
        id: cpr
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        anchors.leftMargin: constants.getPixelSize(50)
        anchors.verticalCenterOffset: constants.getPixelSize(-60)

        Text {
            id: info
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("chest compression left")
            color: constants.highlightedBlueColor
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(18)
            font.family: myFont.name
        }
        Text {
            id: nb
            Layout.alignment: Qt.AlignHCenter
            text: chestPressedCount
            color: "white"
            fontSizeMode: Text.FixedSize
            font.pointSize: constants.getPixelSize(60)
            font.family: myFont.name
        }
        Text {
            id: msg
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("start now")
            color: constants.highlightedBlueColor
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
        text: qsTr("tap screen to find the right heart compress tempo")
        color: "white"
        fontSizeMode: Text.FixedSize
        font.pointSize: constants.getPixelSize(18)
        font.family: myFont.name
        visible: false
        z: 2
    }

    /* Man with graphical effects */
    ManEffects {
        id: man
        anchors.fill: parent

        Image {
            id: heart
            /* relative position versus man body, independant of screen resolution */
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.bottomMargin: constants.manHeight * 0.55 /* heart position from bottom */
            anchors.horizontalCenterOffset: constants.manWidth * 0.04
            source: "/assets/HeartRate_%1/heart_new.png".arg(constants.assetDir)
            z: 2

            /* heart beat animation */
            SequentialAnimation on scale {
                id: heartBeat
                running: true
                loops: -1
                /* heart animation in 2 phases */
                NumberAnimation {
                    id: heartBeatAnim1
                    from: 1
                    to: 1.2
                    duration: (beatValue != 0) ? (60000)/(2*beatValue) : 0
                    easing.type: Easing.InOutCirc
                }
                NumberAnimation {
                    id: heartBeatAnim2
                    from: 1.2
                    to: 1
                    duration: (beatValue != 0) ? (60000)/(2*beatValue) : 0
                    easing.type: Easing.InOutCirc
                }
            }
        }

        /* define area to be pressed */
        Rectangle {
            id: area2press
            width: heart.width * 2
            height: heart.height * 2
            color: "transparent"
            anchors.centerIn: heart

            MouseArea {
                id: pressArea
                anchors.fill: parent
                onPressed: {
                    mouseAreaPressed()
                    if (constants.verboseMode) console.log("heart beat is ", beatValue)
                }
                onReleased: {
                    mouseAreaReleased()
                }
            }
        }

        /* rings around heart with color and gradient */
        Rectangle {
            id: ringsArea
            width: constants.manWidth * 1.5
            height: constants.manWidth * 1.5
            color: "transparent"
            anchors.centerIn: heart
            radius: width/2

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
                color: color1
                visible: true
                antialiasing: true
                opacity: 0.5
                /* Animation on overlay color depending on cursor position */
                SequentialAnimation {
                    id: colorAnim
                    running: false
                    /* color from color 1 to color 8 and then again color 1 */
                    PropertyAnimation  { target: circleOverlay; property: "color"; from: color1; to: color8;
                                         duration: 1000 * (60 / targetPerMinute) }
                    PropertyAnimation  { target: circleOverlay; property: "color"; from: color8; to: color1;
                                         duration: 1000 * (60 / targetPerMinute) }

                }
                SequentialAnimation {
                    id: colorAnimReverse
                    running: false
                    /* and return */
                    PropertyAnimation  { target: circleOverlay; property: "color"; from: circleOverlay.color; to: color1;
                                         duration: (1000 * (60 / targetPerMinute)) / reverseFactor }

                }
            }

            RadialGradient {
                id: grad
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: gradColor}
                    GradientStop { position: 0.5; color: "transparent" }
                }
            }
        }
    }

    /* Heart rate gauge */
    Image {
        id: gauge
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.rightMargin: constants.getPixelSize(50)
        anchors.verticalCenterOffset: constants.getPixelSize(-60)
        source: "/assets/HeartRate_%1/Heart_rate_gauge_bg.png".arg(constants.assetDir)

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

        /* Cursor animation with rings scale */
        PathAnimation {
            id: cursorAnim
            running: true
            loops: 1
            target: cursor
            duration: 500
            path: gaugePath
            anchorPoint: Qt.point(cursor.width/2, cursor.height/2)
        }

        /* rings animation */
        SequentialAnimation {
            id: ringsAnim
            running: false
            loops: 1
            NumberAnimation {
                target: ringsArea
                property: "scale"
                from: 1
                to: 1.2
                duration: 1000 * (60 / targetPerMinute)
            }
            NumberAnimation {
                target: ringsArea
                property: "scale"
                from: 1.2
                to: 1
                duration: 1000 * (60 / targetPerMinute)
            }
        }

        /* Reverse case */
        SequentialAnimation {
            id: ringsAnimReverse
            running: false
            loops: 1
            NumberAnimation {
                target: ringsArea
                property: "scale"
                from: ringsArea.scale
                to: 1
                duration: (1000 * (60 / targetPerMinute)) / reverseFactor
            }
        }

        /* heart info */
        ColumnLayout {
            id: heartInfo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: constants.getPixelSize(20)
            Text {
                id: heartRate
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("heart rate")
                color: constants.highlightedBlueColor
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(13)
                font.family: myFont.name
            }
            Text {
                id: heartFreq
                Layout.alignment: Qt.AlignHCenter
                text: (beatValid) ? beatValue : 0
                color: "white"
                fontSizeMode: Text.FixedSize
                font.pointSize: constants.getPixelSize(40)
                font.family: myFont.name
            }
            /* heart beat animated image */
            Image {
                id: pulse
                source: "/assets/HeartRate_%1/Heartbeat_frames/HeartBeat_".arg(constants.assetDir)+idx+".png"
                Layout.alignment: Qt.AlignHCenter
                property int idx:1
                /* Animation trick to avoid gif uggly rendering. 32 fps movement */
                NumberAnimation on idx {
                    id: pulseAnim
                    running: beatValid
                    from: 1; to: 32; duration: 1000; loops: -1
                }
            }
        }
    }

}
