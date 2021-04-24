#!/bin/zsh
# 真正地控制并发去下载

# 当前已更新的集数
num=28

# 当前下载进程数
cur_down_num=0
# 最大下载进程数
max_down_num=5

for((index=1;index<=${num};index++)); do
    url=$(head -n 1 ${index}.m3u8_url)
    echo "index=${index}, url=${url}"
    sh down_mp4.sh ${url} ${index}.mp4 &
    cur_down_num=$((${cur_down_num}+1))
    if [ ${cur_down_num} -gt ${max_down_num} ]; then
        wait
        cur_down_num=0
    fi
done
