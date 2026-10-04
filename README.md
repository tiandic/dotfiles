# dotfiles
这里是我的配置文件

该仓库为了更好地利用其他仓库的插件,所以将`ohmyzsh`等仓库作为了子模块,需要使用如下命令拉取:
```
git clone --recursive https://github.com/tiandic/dotfiles.git
```

以下是需要进行额外工作的配置
## niri
niri 不允许单个`Win`键作为快捷键打开rofi,所以要额外配置

```
# /etc/keyd/default.conf

[ids]
*

[global]
overload_tap_timeout = 300

[main]
leftmeta = overload(meta, macro(leftmeta+0))
```
以上`keyd`配置会让单击`Win`键变为`Win`+`0`, 而niri配置中设置了`Win`+`0`打开niri

所以最终效果是单击`Win`会打开rofi
