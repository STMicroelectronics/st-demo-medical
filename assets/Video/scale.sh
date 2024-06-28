# Command used to resize fullhd video to hd
ffmpeg -i heart_1920_fullhd.mp4 -vf scale="1280:720" heart_1920.mp4
ffmpeg -i air_1920_fullhd.mp4 -vf scale="1280:720" air_1920.mp4
