#!/bin/sh

# 开始的集数
START_INDEX=1
# 结束的集数
END_INDEX=28

# ffmpeg解码线程数
THREAD_NUM=4

# 打印日志
function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] "$@
    return 0
}

# 提取m3u8 url
function get_m3u8_url() {
    log "get_m3u8_url start"

    for ((index=${START_INDEX};index<=${END_INDEX};index++)); do
        local url=www.xjxsjyy.com/index.php/xp/yuzhaolingdiyiji-1-${index}.html
        log "get_m3u8_url, index=${index}, url=${url}"
        curl ${url} 2>&2 | grep -e "\"url\":\"\S*\",\"url_next" -o | awk -F '"url":"' '{print $2}' | awk -F '"' '{print $1}' | sed -e "s/\\\\\//\//g" >${index}.m3u8_url 2>&2 &
    done

    log "get_m3u8_url gettting......"
    wait
    log "get_m3u8_url finish"

    return 0
}

# 真正下载m3u8文件并拼接
function down_m3u8() {
    log "down_m3u8 start"

    for ((index=${START_INDEX};index<=${END_INDEX};index++)); do
        local m3u8_url=$(head -n 1 ${index}.m3u8_url)
        log "down_m3u8, index=${index}, m3u8_url=${m3u8_url}"
        ffmpeg -nostdin -i ${m3u8_url} -vcodec copy -threads ${THREAD_NUM} -preset ultrafast -y ${index}.mp4 &>down_${index}.log &
    done

    log "down_m3u8 downloading......"
    wait
    log "down_m3u8 finish"

    return 0
}

# 读取参数配置
function init_config() {
    if [ $# -gt 2 ]; then
        log "param error, param num is $#, param num is greater than 2, exit"
        return 1
    elif [ $# -eq 2 ]; then
        local set_start_index=$1
        local set_end_index=$2
        if [ ${set_start_index} -le 0 ] || [ ${set_end_index} -le 0 ]; then
            log "param error, set_start_index is ${set_start_index}, set_end_index is ${set_end_index}, set_start_index or set_end_index is less than or equal to 0, exit"
            return 1
        elif [ ${set_start_index} -gt ${set_end_index} ]; then
            log "param error, set_start_index is ${set_start_index}, set_end_index is ${set_end_index}, set_start_index is greater than set_end_index, exit"
            return 1
        fi
        START_INDEX=${set_start_index}
        END_INDEX=${set_end_index}
    elif [ $# -eq 1 ]; then
        local set_start_end_index=$1
        if [ ${set_start_end_index} -le 0 ]; then
            log "param error, set_start_end_index is ${set_start_end_index}, set_start_end_index is less than or equal to 0, exit"
            return 1
        fi
        START_INDEX=${set_start_end_index}
        END_INDEX=${set_start_end_index}
    fi

    return 0
}

# 主函数
function main() {
    init_config $@
    local ret=$?
    if [ ${ret} -ne 0 ]; then
        return ${ret}
    fi

    log "start"
    log "START_INDEX=${START_INDEX}, END_INDEX=${END_INDEX}"

    get_m3u8_url
    down_m3u8

    log "finish"

    return 0
}

main $@
