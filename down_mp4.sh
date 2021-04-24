#!/bin/zsh
# 解决ffmpeg无法直接扔后台的问题

in=$1
out=$2

ffmpeg -i ${in} ${out}
