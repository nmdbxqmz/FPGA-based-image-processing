# -*- coding: utf-8 -*-
# @Time    : 2025/3/7 15:49
# @Author  : licheng
# @File    : gamma.py

gamma = 0.8                 #gamma值定义
open("./gamma.coe", "w")    #创建coe文件

line = "memory_initialization_radix=16;\n\n"    #使用16进制
line += "memory_initialization_vector= \n\n"

# 计算gamma值
for i in range(256):
    y = round(pow(i/255, gamma) * 255)          #gamma值计算公式
    if i < 255:
        line += '0x{:02X}'.format(y)[2:] + ",\n"    #其他的数值结尾为,
    else:
        line += '0x{:02X}'.format(y)[2:] + ";"      #最后一个数值结尾为;

# 写入文件
with open("./gamma.coe", "w+") as f:
    f.writelines(line)