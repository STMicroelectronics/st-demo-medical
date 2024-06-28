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

#include "systeminfo.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QString>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    /* Parsing command line */
    QCommandLineParser parser;
    parser.setApplicationDescription("STMicroelectronics medical demo for STM32MP2");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption windowModeOption("windowMode",
                                        "Open the demo in window mode, not in fullscreen");
    parser.addOption(windowModeOption);

    QCommandLineOption debugMsgOption("debugMsg",
                                      "Print debug messages");
    parser.addOption(debugMsgOption);

    QCommandLineOption noperfOption("noperf",
                                    "Hide performance info");
    parser.addOption(noperfOption);

    parser.process(app);

    /* QML engine */
    QQmlApplicationEngine engine;
    qmlRegisterType<SystemInfo>("SystemInfo", 1, 0, "SystemInfo");

    /* Apply command line options */
    engine.rootContext()->setContextProperty("_windowVisibility", QVariant::fromValue(parser.isSet(windowModeOption)));
    engine.rootContext()->setContextProperty("_debugMsg", QVariant::fromValue(parser.isSet(debugMsgOption)));
    engine.rootContext()->setContextProperty("_noperf", QVariant::fromValue(parser.isSet(noperfOption)));

    #ifdef Q_OS_WIN
        // On Windows simulator for testing with videos added in qrc file. And gst-pipeline is not used.
        engine.rootContext()->setContextProperty("_videoRootDir", "/assets/Video/");
        engine.rootContext()->setContextProperty("_videoPrefixCmd", "");
        engine.rootContext()->setContextProperty("_videoSuffixCmd", "");
    #else
        // gst-pipeline is used for both Linux simulator and STM32 linux target
        engine.rootContext()->setContextProperty("_videoRootDir", "/usr/local/demo/medical/videos/");
        engine.rootContext()->setContextProperty("_videoPrefixCmd", "gst-pipeline: filesrc location=");
        #ifdef Q_PROCESSOR_X86
            // Linux simulator
            engine.rootContext()->setContextProperty("_videoSuffixCmd", " ! decodebin name=dec ! videoconvert ! autovideosink");
        #else
            // On STM32MPU target
            engine.rootContext()->setContextProperty("_videoSuffixCmd", " ! qtdemux ! h264parse ! v4l2slh264dec ! autovideosink");
        #endif
    #endif

    QObject::connect((QObject*)&engine, SIGNAL(quit()), &app, SLOT(quit()));

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
