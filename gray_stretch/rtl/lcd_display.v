module lcd_display
(
    input                lcd_pclk,    //时钟
    input                rst_n,       //复位，低电平有效
    input        [10:0]  pixel_xpos,  //当前像素点横坐标
    input        [10:0]  pixel_ypos,  //当前像素点纵坐标  
    input        [10:0]  h_disp,      //LCD屏水平分辨率
    input        [10:0]  v_disp,      //LCD屏垂直分辨率       
    output  reg  [23:0]  pixel_data   //像素数据
);

//parameter define                   
localparam PIC_X_START  = 11'd2;      //图片起始点横坐标(>=2)
localparam PIC_X_DIVIDE = 11'd300;    //图片横坐标相差距离
localparam PIC_Y_START  = 11'd0;      //图片起始点纵坐标(>=0)
localparam PIC_WIDTH    = 11'd250;    //图片宽度
localparam PIC_HEIGHT   = 11'd250;    //图片高度
localparam WHITE 		= 24'hFFFFFF; 

//reg define
reg   [15:0]  rom_addr_pic;  		//ROM地址(原图)
reg   [15:0]  rom_addr_gray;  		//ROM地址(灰度)
reg	  [7:0]   gray;					//灰度像素值

//wire define   
wire  [15:0]  rom_addr;  			//ROM地址
wire          rom_rd_en ;  			//ROM读使能信号
wire  [23:0]  rom_rd_data ;			//ROM数据

//*****************************************************
//**                    main code
//*****************************************************
assign  rom_rd_en = 1'b1;                  //读使能拉高，即一直读ROM数据
assign 	rom_addr = ((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT)) ? rom_addr_pic:rom_addr_gray;				

//根据当前像素点坐标指定当前像素点颜色数据
always @(posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_data <= WHITE;
    else 
		begin
			if( (pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
				&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
				pixel_data <= rom_rd_data;  //显示图片
			else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
				&& (pixel_xpos >= PIC_X_START + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH + PIC_X_DIVIDE))
				begin
					if(gray < 9'd255)
						pixel_data <= {3{gray[7:0]}};
					else
						pixel_data <= 24'hFFFFFF;
				end
			else
				pixel_data <= WHITE;    
		end  
end

//根据当前扫描点的横纵坐标为ROM地址(原图)赋值
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_pic <= 16'd0;
    //当横纵坐标位于图片显示区域时,累加ROM地址    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 1'd1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1)) 
        rom_addr_pic <= rom_addr_pic + 1'd1;
    //当横纵坐标位于图片区域最后一个像素点时,ROM地址清零    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr_pic <= 16'd0;
	else
		rom_addr_pic <= rom_addr_pic;
end

//根据当前扫描点的横纵坐标为ROM地址(灰度)赋值
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_gray <= 16'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
			&& (pixel_xpos >= PIC_X_START - 1'd1 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1 + PIC_X_DIVIDE)) 
        rom_addr_gray <= rom_addr_gray + 1'd1;
    else if(pixel_ypos >= PIC_Y_START + PIC_HEIGHT)
        rom_addr_gray <= 16'd0;
	else
		rom_addr_gray <= rom_addr_gray;
end

//计算灰度值
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		gray <= 9'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
			&& (pixel_xpos >= PIC_X_START - 1'd1 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1 + PIC_X_DIVIDE)) 
		gray <=	((((29*rom_rd_data[7:0] + 150*rom_rd_data[15:8] + 76*rom_rd_data[23:16]) >> 8)*589) >> 9);
	else
		gray <= gray;
end

//ROM：存储图片
blk_mem_gen_0  blk_mem_gen_0 
(
	.clka  (lcd_pclk),    // input wire clka
	.ena   (rom_rd_en),   // input wire ena
	.addra (rom_addr),    // input wire [16 : 0] addra
	.douta (rom_rd_data)  // output wire [23 : 0] douta
);

endmodule
