#!/bin/python3

import os


config_path=os.path.join(os.environ["HOME"],".config/niri/config.kdl")

with open(config_path) as f:
    text=f.read()

text2=text.replace("touchpad {\n        // off","touchpad {\n        off")

if text==text2:
    text2=text.replace("touchpad {\n        off","touchpad {\n        // off")


with open(config_path,'w') as f:
    f.write(text2)
