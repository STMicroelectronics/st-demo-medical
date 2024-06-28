#
# @attention
#
# Copyright (c) 2024 STMicroelectronics.
# All rights reserved.
#
# This software is licensed under terms that can be found in the LICENSE file
# in the root directory of this software component.
# If no LICENSE file comes with this software, it is provided AS-IS.
#

QT += quick svg

HEADERS += \
    $$files(src/*.h) \
    $$files(src/*.hpp)

SOURCES += \
    $$files(src/*.c) \
    $$files(src/*.cpp)

RESOURCES += \
qml.qrc

win32 {
    RESOURCES += videos.qrc
}

FORMS +=

unix {
    INSTALLS += videos

    videos.path = /usr/local/demo/medical/videos
    videos.files = assets/Video/air_1024.mp4 \
                   assets/Video/air_1920.mp4 \
                   assets/Video/heart_1024.mp4 \
                   assets/Video/heart_1920.mp4 \
                   assets/Video/air_1280.mp4 \
                   assets/Video/heart_1280.mp4

}

# Default rules for deployment.
unix {
    target.path = /usr/local/demo/medical
    INSTALLS += target
}

DISTFILES +=

