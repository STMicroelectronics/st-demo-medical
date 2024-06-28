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
    id: videoComponent
    width: constants.screenWidth
    height: constants.screenHeight

    property string sourceFile: "heart_%1.mp4".arg(constants.assetVideoDir)

    function reloadCurrentView() {
        if (constants.verboseMode) console.debug("reloadCurrentView: ", stackView.state)

        /* in case collision between concurrent calls of reloadCurrentView */
        if (stackView.depth >= 2) stackView.pop()

        if (constants.verboseMode) console.debug("Stack depth is ", stackView.depth)
        if (stackView.state === 'HeartRate') {
            if (constants.selfDemoMode) {
                if (constants.verboseMode) console.debug("Load HeartRate in demo mode");
                stackView.push("/qml/HeartRate.qml", {"demoMode": "true"})
            }
            else {
                stackView.push("/qml/HeartRate.qml")
            }
            /* reactivate status bar masked during video */
            statusBar.visible = true
        }
        else if (stackView.state === 'BlowAir') {
            if (constants.selfDemoMode) {
                if (constants.verboseMode) console.debug("Load BlowAir in demo mode");
                stackView.push("/qml/BlowAir.qml", {"demoMode": "true"})
            }
            else {
                stackView.push("/qml/BlowAir.qml")
            }
            /* reactivate status bar masked during video */
            statusBar.visible = true
        }
        else if (stackView.state === 'SecureAirways') {
            if (constants.selfDemoMode) {
                if (constants.verboseMode) console.debug("Load SecureAirways in demo mode");
                stackView.push("/qml/SecureAirways.qml", {"demoMode": "true"})
            }
            else {
                stackView.push("/qml/SecureAirways.qml")
            }
            /* reactivate status bar masked during video */
            statusBar.visible = true
        }
        else {
            if (constants.verboseMode) console.debug("reload Startup (default)")
            stackView.pop(null)
            stackView.state = 'Startup'
            if (constants.selfDemoMode) {
                if (constants.verboseMode) console.debug("Load Startup in demo mode");
                stackView.push("/qml/Startup.qml", {"demoMode": "true"})
            }
            else {
                stackView.push("/qml/Startup.qml")
            }
        }
        if (constants.verboseMode) console.debug("reloadCurrentView done, view is :", stackView.state)
        if (constants.verboseMode) console.debug("Stack depth is ", stackView.depth)
    }

    function playVideo() {
        if (constants.verboseMode) console.debug("video status" + player.playbackState)
        if (player.playbackState == MediaPlayer.StoppedState) {
            player.playbackRate = 1
        }

        /* When video finished, unload video component, and reload main menu */
        if (player.status == MediaPlayer.EndOfMedia ) {
            /* reload current view */
            reloadCurrentView()
            /* Unload video view */
            videoLoader.active = false
        }
    }

    /* To get black screen when loading new data in fast forward */
    Rectangle {
        id: videoBg
        anchors.fill: parent
        color: "black" // "transparent" to check unload/load process
        z: -1
    }

    /* help video */
    MediaPlayer {
        id: player
        /* use HD stream with rescaling in case of full HD display to reduce footprint */
        source: _videoPrefixCmd + _videoRootDir + sourceFile + _videoSuffixCmd
        autoPlay: true
        playbackRate: 1
        onStatusChanged:
        {
            if (constants.verboseMode) console.debug("MediaPlayer source: " + player.source);
            playVideo();
        }
    }

    VideoOutput {
        anchors.centerIn: parent
        anchors.fill: parent // will be played full screen if video resolution is smaller
        //fillMode: VideoOutput.Stretch
        source: player
    }

    /* video buttons */
    Image {
        id: videoButtonGroup
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        source: "/assets/BlowAir_%1/video/video_tab.png".arg(constants.assetDir)
        visible: true
        z: 1

        ButtonGroup {
            buttons: row.children
        }

         /* video tab image is not rectangle: edges are truncated. So needs to use smaller rectangle before layout */
        Rectangle {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
            width: videoButtonGroup.width / 2
            height: videoButtonGroup.height
            color: "transparent"
            RowLayout {
                id: row
                anchors.centerIn: parent
                anchors.bottomMargin: constants.getPixelSize(10)
                //spacing: constants.getPixelSize(20)

                /* no sound support */
                Button {
                    id: soundButton
                    Layout.preferredWidth: img0.width * 1.5
                    Layout.preferredHeight: img0.height * 1.5
                    Image {
                        id: img0
                        anchors.centerIn: parent
                        source: "/assets/BlowAir_%1/video/video_icon_sound_off_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: false
                    checked: false
                    onClicked: {
                    }
                }

                Button{
                    id: restartButton
                    /* wider click area */
                    Layout.preferredWidth: img1.width * 1.5
                    Layout.preferredHeight: img1.height * 1.5
                    Image {
                        id: img1
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_start_over_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_start_over_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: false
                    onPressed: {
                        restartButton.checked = true /* to be able to see highlighted effect */
                    }
                    onReleased: {
                        player.playbackRate = 1
                        player.seek(0)
                        player.play()             /* in case pause was done before */
                        playButton.checked = true /* trigger play event */
                    }
                    onCanceled: {
                        restartButton.checked = false
                    }
                }

                /* backward not supported: make as restart */
                Button{
                    id: backwardButton
                    Layout.preferredWidth: img2.width * 1.5
                    Layout.preferredHeight: img2.height * 1.5
                    Image {
                        id: img2
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_rew_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_rew_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: false
                    onPressed: {
                        backwardButton.checked = true /* to be able to see highlighted effect */
                    }
                    onReleased: {
                        player.playbackRate = 1
                        player.seek(0)
                        player.play()             /* in case pause was done before */
                        playButton.checked = true /* trigger play event */
                    }
                    onCanceled: {
                        backwardButton.checked = false
                    }
                }

                Button{
                    id: playButton
                    Layout.preferredWidth: img3.width * 1.5
                    Layout.preferredHeight: img3.height * 1.5
                    Image {
                        id: img3
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_play_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_play_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: true
                    onClicked: {
                        player.playbackRate = 1
                        player.play()
                    }
                }

                Button{
                    id: pauseButton
                    Layout.preferredWidth: img4.width * 1.5
                    Layout.preferredHeight: img4.height * 1.5
                    Image {
                        id: img4
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_pause_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_pause_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: false
                    onClicked: {
                        player.pause()
                        player.playbackRate = 1
                    }
                }

                Button{
                    id: fowardButton
                    Layout.preferredWidth: img5.width * 1.5
                    Layout.preferredHeight: img5.height * 1.5
                    Image {
                        id: img5
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_ffw_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_ffw_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: false
                    onClicked: {
                        player.playbackRate = 2
                        player.play()
                    }
                }

                Button{
                    id: exitButton
                    Layout.preferredWidth: img6.width * 1.5
                    Layout.preferredHeight: img6.height * 1.5
                    Image {
                        id: img6
                        anchors.centerIn: parent
                        source: parent.checked ? "/assets/BlowAir_%1/video/video_icon_exit_pressed.png".arg(constants.assetDir)
                                               : "/assets/BlowAir_%1/video/video_icon_exit_normal.png".arg(constants.assetDir)
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    checkable: true
                    checked: false
                    onPressed: {
                        exitButton.checked = true /* to be able to see highlighted effect */
                    }
                    onReleased: {
                        player.playbackRate = 1
                        player.stop()
                        /* reload current view */
                        reloadCurrentView()
                        /* Unload video */
                        videoLoader.active = false
                    }
                    onCanceled: {
                        exitButton.checked = false
                    }
                }
            }
        }
    }
}
