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

project(medical)
cmake_minimum_required(VERSION 3.9)

find_package(Qt5Core CONFIG REQUIRED)
find_package(Qt5Gui CONFIG REQUIRED)
find_package(Qt5Network CONFIG REQUIRED)
find_package(Qt5Qml CONFIG REQUIRED)
find_package(Qt5QmlModels CONFIG REQUIRED)
find_package(Qt5Quick CONFIG REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC TRUE)
set(CMAKE_AUTORCC TRUE)

if (WIN32)
add_executable(medical
  src/main.cpp
  src/systeminfo.cpp
  qml.qrc
  videos.qrc
)
endif (WIN32)

if (UNIX)
add_executable(medical
  src/main.cpp
  src/systeminfo.cpp
  qml.qrc
)
endif (UNIX)

target_link_libraries(medical Qt5::Core Qt5::Gui Qt5::Quick)

install(TARGETS medical RUNTIME DESTINATION bin)

if (UNIX)
    install(FILES assets/Video/air_1024.mp4 assets/Video/air_1920.mp4 assets/Video/heart_1024.mp4 assets/Video/heart_1920.mp4 assets/Video/air_1280.mp4 assets/Video/heart_1280.mp4 DESTINATION /usr/local/demo/medical/videos)
endif (UNIX)

