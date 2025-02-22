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
* 在Native Ports中，读模式选择First Word Fall Through，修改写位宽和写深度，写位宽应等于传入图像的像素点位数，写深度应大于等于传入图像的宽度，最后复位模式选择异步复位，如下图所示：
  ![](https://github.com/nmdbxqmz/FPGA-based-image-processing/blob/main/images/fifo_native.png)
  
