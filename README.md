# FPGA-based-image-processing

## 说明
* 本仓库使用的板卡为正点原子的达芬奇A7，请根据自己实际的板卡资源对相关参数进行调整
* lcd驱动使用的是正点原子的例程（魔改版），只支持800×480分辨率的lcd，请根据自己实际的lcd型号对lcd相关参数进行调整
* 行缓存思路参考：
  >https://blog.csdn.net/qq_39507748/article/details/115269289
* 仓库中每一个文件夹对应一种图像处理方法，其中rtl文件夹装有源码，.coe文件为写入FPGA内部ROM的图像数据

## ROM ip核配置
*  仓库中所有的图像处理方法都需要配置ip核
*  这里只给出需要手动修改的配置，其他配置保持默认即可
*  打开ROM ip核的配置，在Basic中将存储类型改为单口ROM，如下图所示：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/rom_basic.png)
*  在Port A Options中，修改位宽和深度，位宽应等于传入图像的像素点位宽，深度应大于等于传入图像的像素点个数，取消勾选输出缓存，如下图所示：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/rom_port.png)
*  在Other Options中，勾选从文件中加载，并点击浏览，将.coe文件的路径添加进去，如下图所示：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/rom_other.png)

## FIFO ip核配置
* average、corrode、dilate、gaussian3、gaussian5，middle、sobel需要配置该ip核
* 这里只给出需要手动修改的配置，其他配置保持默认即可
* 在Native Ports中，读模式选择First Word Fall Through，修改写位宽和写深度，写位宽应等于传入图像的像素点位宽，写深度应大于等于传入图像的宽度，最后复位模式选择异步复位，如下图所示：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/fifo_native.png)

## 特殊工程说明
* 即除了需要配置上述的ROM和FIFO外，还需要进行一些额外操作的项目
### gray_gamma
* 因为FPGA进行指数计算比较麻烦，所以该工程使用python计算出0~255的灰度值经过gamma变换后对应的值并生成coe文件，然后存入ROM中，这样就可以根据当前灰度值去ROM中找到gamma变换后对应的值
* [gamma.py](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/gray_gamma/gamma.py)是用来计算0~255的灰度值经过gamma变换后对应的值并生成coe文件的程序，在使用过程中只需要修改如下图所示的gamma值即可：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/gamma_py.png)
* 在执行完上面的ROM IP核配置后，这里还需要额外配置一个ROM来存储gamma变换后对应的灰度值，在Port A Options中修改位宽为8、深度为256，其余配置和上面的一样（注：默认第一个ROM IP核名称为blk_mem_gen_0，第二个为blk_mem_gen_1，因为在.v文件中blk_mem_gen_0存储的为原图，blk_mem_gen_1存储的为gamma变换后对应的灰度值，所以生成ROM IP核的顺序不要弄错了）
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/gamma_rom.png)
  
