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

#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QElapsedTimer>
#include <QObject>
#include <QQmlParserStatus>
#include <QMutex>

class SystemInfo : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(double percent READ percent NOTIFY percentChanged)
    Q_PROPERTY(double fps READ fps NOTIFY fpsChanged)
    Q_PROPERTY(double gpuPercent READ gpuPercent NOTIFY gpuPercentChanged)
    Q_INTERFACES(QQmlParserStatus)

public:
    explicit SystemInfo(QObject *parent = nullptr);
    void classBegin() final {}
    void componentComplete() final;


    double percent() const;
    double fps() const { return m_fps; }

    double gpuPercent() const;

private:
    void setPercent(double newPercent);
    void setFps(double newFps);

    void setGpuPercent(double newPercent);

signals:
    void percentChanged();
    void fpsChanged();

    void gpuPercentChanged();

private:
    double m_percent = 0;
    int m_prevIdleTime = 0;
    int m_prevTotalTime = 0;
    QMutex m_mutex;
    int m_frames = 0;
    double m_fps = 0;

    double m_gpuPercent = 0;
    double m_prevGpuOnTime = 0;
    double m_prevGpuOffTime = 0;
    double m_prevGpuIdleTime = 0;
    double m_prevGpuSuspendTime = 0;
    bool m_fileDebugPrintDone = false;
    bool m_fileDebugPrintDone2 = false;

};

#endif // SYSTEMINFO_H
