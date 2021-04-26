#!/bin/sh

# 开始的集数
START_INDEX=1
# 结束的集数
END_INDEX=28

# ffmpeg解码线程数
THREAD_NUM=4

# 提取m3u8 url
function get_m3u8_url() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] get_m3u8_url start"

    for ((index=${START_INDEX};index<=${END_INDEX};index++)); do
        local url=www.xjxsjyy.com/index.php/xp/yuzhaolingdiyiji-1-${index}.html
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] get_m3u8_url, index=${index}, url=${url}"
        curl ${url} 2>&2 | grep -e "\"url\":\"\S*\",\"url_next" -o | awk -F '"url":"' '{print $2}' | awk -F '"' '{print $1}' | sed -e "s/\\\\\//\//g" >${index}.m3u8_url 2>&2 &
    done

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] get_m3u8_url gettting......"
    wait
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] get_m3u8_url finish"
}

# 真正下载m3u8文件并拼接
function down_m3u8() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] down_m3u8 start"

    for ((index=${START_INDEX};index<=${END_INDEX};index++)); do
        local m3u8_url=$(head -n 1 ${index}.m3u8_url)
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] down_m3u8, index=${index}, m3u8_url=${m3u8_url}"
        ffmpeg -nostdin -i ${m3u8_url} -vcodec copy -threads ${THREAD_NUM} -preset ultrafast -y ${index}.mp4 &>down_${index}.log &
    done

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] down_m3u8 downloading......"
    wait
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] down_m3u8 finish"
}

# 主函数
function main() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] start"

    get_m3u8_url
    down_m3u8

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] finish"
}

main
