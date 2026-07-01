#!/bin/bash

# 此脚本用于使用单个 Win 打开/关闭 rofi

if ps aux | grep -v grep | grep "rofi -show" -q; then
  killall rofi
else
  rofi -show drun -show-icons
fi
