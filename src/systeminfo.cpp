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

#include <QFile>
#include <QQuickWindow>
#include <QTimer>

SystemInfo::SystemInfo(QObject *parent)
    : QObject{parent}
{
    auto timer = new QTimer{this};
    auto readStat = [this] {
        QFile file(QStringLiteral("/proc/stat"));

        setPercent(-1);
        if (!file.open(QFile::ReadOnly)) {
            if (!m_fileDebugPrintDone2) {
                qDebug() << "Cannot open /proc/stat file (CPU info)";
                m_fileDebugPrintDone2 = true;
            }
            return;
        }
        const auto times = file.readLine().simplified().split(' ').mid(1);
        const int idleTime = times.at(3).toInt();
        int totalTime = 0;
        for (const auto &time : times)
            totalTime += time.toInt();
        setPercent(100.0 * (1 - double(idleTime - m_prevIdleTime) / double(totalTime - m_prevTotalTime)));
        m_prevIdleTime = idleTime;
        m_prevTotalTime = totalTime;
        QMutexLocker lock(&m_mutex);
        setFps(m_frames * 2);
        m_frames = 0;
    };
    connect(timer, &QTimer::timeout, this, readStat);
    readStat();

    auto readGpuStat = [this] {
        QFile fileGpu(QStringLiteral("/sys/kernel/debug/gc/idle"));

        setGpuPercent(-1);
        if (!fileGpu.open(QFile::ReadOnly)) {
            if (!m_fileDebugPrintDone) {
                qDebug() << "\nCannot open /sys/kernel/debug/gc/idle file (GPU info). Must be root!\n";
                m_fileDebugPrintDone = true;
            }
            return;
        }
        QByteArray fileData = fileGpu.readAll();
        QString text(fileData);
        text.replace(QString(","), QString(""));
        const auto times = text.simplified().split(' ').mid(0);

        const auto onTime = times.at(1).toDouble();
        const auto offTime = times.at(4).toDouble();
        const auto idleTime = times.at(7).toDouble();
        const auto suspendTime = times.at(10).toDouble();

        setGpuPercent(100.0 * (double(onTime - m_prevGpuOnTime) / double(onTime + offTime + idleTime + suspendTime
                                                                   - m_prevGpuOnTime - m_prevGpuOffTime - m_prevGpuIdleTime - m_prevGpuSuspendTime)));

        m_prevGpuOnTime = onTime;
        m_prevGpuOffTime = offTime;
        m_prevGpuIdleTime = idleTime;
        m_prevGpuSuspendTime = suspendTime;
        QMutexLocker lock(&m_mutex);
    };

    connect(timer, &QTimer::timeout, this, readGpuStat);
    readGpuStat();

    timer->start(500);
}

void SystemInfo::componentComplete()
{
    QObject *p = parent();
    while (p) {
        if (auto w = qobject_cast<QQuickWindow *>(p)) {
            connect(w, &QQuickWindow::frameSwapped, this, [this]{
                    QMutexLocker lock(&m_mutex);
                    ++m_frames;
                }, Qt::DirectConnection);
            break;
        }
        p = p->parent();
    }
}

double SystemInfo::percent() const
{
    return m_percent;
}

void SystemInfo::setPercent(double newPercent)
{
    newPercent = qRound(newPercent * 100 / 100.00) ;
    m_percent = newPercent;
    emit percentChanged();
}

void SystemInfo::setFps(double newFps)
{
    if (qFuzzyCompare(m_fps, newFps))
        return;
    m_fps = newFps;
    emit fpsChanged();
}

double SystemInfo::gpuPercent() const
{
    return m_gpuPercent;
}

void SystemInfo::setGpuPercent(double newPercent)
{
    m_gpuPercent = qRound(newPercent);
    emit gpuPercentChanged();
}
