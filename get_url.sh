#!/bin/zsh
# 提取真正的m3u8地址

# 当前已更新的集数
num=28

for((index=1;index<=${num};index++)); do
    echo "index=${index}"
    url=www.xjxsjyy.com/index.php/xp/yuzhaolingdiyiji-1-${index}.html
    curl ${url} -o ${index}.html
    cat ${index}.html | grep -e "\"url\":\"\S*\",\"url_next" -o | awk -F '"url":"' '{print $2}' | awk -F '"' '{print $1}' | sed -e "s/\\\\\/\\\\\//\\/\\//g" -e "s/\\\\\//\//g" >${index}.m3u8_url
done
