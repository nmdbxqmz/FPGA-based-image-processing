# -*- coding: utf-8 -*-
# @Time    : 2025/3/19 20:43
# @Author  : licheng
# @File    : rom.py
import cv2

img_path = "./lena_gray.png"                #图片路径
img_width = "rgb"                          #gray=8 rgb=24
rom_depth = 62500                           #rom深度
tab = "    "

def rom_create(img_path, img_width, rom_depth):
    """
    创建rom.v文件
    Args:
        img_path: 图片路径
        img_width: 像素点位宽
        rom_depth: rom深度

    Returns:none
    """
    pixel_width = 24            #像素点位宽
    addr_width = 1              #地址位数

    open("./rom.v", "w")        #创建rom.v文件
    # 判断参数是否错误
    img = cv2.imread(img_path)
    w, h = img.shape[1], img.shape[0]
    if w * h > rom_depth:
        print("数组深度定义过小")
        return
    while 2 ** addr_width < rom_depth:
        addr_width = addr_width + 1            #计算addr位数
    if img_width != "gray" and img_width != "rgb":
        print("像素点位宽定义错误")
        return
    if img_width == "gray":
        img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        pixel_width = 8
        img_list = img.reshape((w * h))
    else:
        img_list = img.reshape((w * h, 3))
    # 模块定义
    line = "module blk_mem_gen_0\n(\n"
    line += tab + "input				clka,\n"
    line += tab + "input				ena,\n"
    line += tab + "input		[" + str(addr_width-1) + ":0]	addra,\n"
    if img_width == 8:
        line += tab + "output	reg	[7:0]	douta\n"
    else:
        line += tab + "output	reg	[23:0]	douta\n"
    line += ");\n\n"

    # 数组定义
    line += "reg [" + str(pixel_width-1) + ":0] rom [" + str(rom_depth-1) + ":0];\n\n"

    # 数组初始化
    line += "initial\nbegin\n"
    if img_width == "rgb":
        for i in range(w * h):
            line += tab + "rom[" + str(i) + "] <= " + str(pixel_width) + "'d" + str(img_list[i][1]*256*256 + img_list[i][1]*256 + img_list[i][1]) + ";\n"
        line += "end\n\n"
    else:
        for i in range(w * h):
            line += tab + "rom[" + str(i) + "] <= " + str(pixel_width) + "'d" + str(img_list[i]) + ";\n"
        line += "end\n\n"

    # rom逻辑
    line += "always @(posedge clka)\nbegin\n"
    line += tab + "if(ena)\n"
    line += tab + tab + "douta <= rom[addra];\n"
    line += tab + "else\n"
    line += tab + tab + "douta <= douta;\nend\n\n"
    line += "endmodule"

    # 写入文件
    with open("./rom.v", "w+") as f:
        f.writelines(line)

# 函数调用
rom_create(img_path, img_width, rom_depth)