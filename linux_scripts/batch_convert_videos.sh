#!/bin/bash
# Credits
# https://www.ryananddebi.com/2020/10/31/linux-batch-convert-avi-files-to-mp4-mkv/

original_video_format='.avi'
new_video_format='.mp4'

for i in *."${original_video_format}"; do
    ffmpeg -i "$i" "${i%.*}.${new_video_format}"
done
