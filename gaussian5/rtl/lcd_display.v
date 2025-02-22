parameter  PIC_WIDTH    = 11'd250;    //图片宽度
parameter  PIC_HEIGHT   = 11'd250;    //图片高度
parameter  WIDTH 		= 24;		  //数据位宽

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
localparam PRE_READ_NUM = 11'd750;	  //预读像素点数量(=3×PIC_WIDTH)
localparam WHITE 		= 24'hFFFFFF; 

//reg define
reg   [15:0]  rom_addr_pic;  		//ROM地址(图片)
reg	  [9:0]   cnt_buffer;
reg			  buffer_valid_in;
reg   [15:0]  rom_addr_buffer;  	//ROM地址(行缓存)
reg			  matrix_valid_in;

//wire define   
wire  [15:0]  		rom_addr;  		//ROM地址
wire          		rom_rd_en ;  	//ROM读使能信号
wire  [WIDTH-1:0]  	rom_rd_data ;	//ROM数据
wire  [WIDTH-1:0] 	buffer_dout1;
wire  [WIDTH-1:0]  	buffer_dout2;
wire  [WIDTH-1:0]  	buffer_dout3;
wire  [WIDTH-1:0] 	buffer_dout4;
wire  [WIDTH-1:0]  	buffer_dout5;
wire		 		rst_fifo;
wire				rd_en_all;			
wire		  		fifo_rst_busy;
wire  [WIDTH-1:0]  	matrix_dout;

//*****************************************************
//**                    main code
//*****************************************************
assign  rom_rd_en = 1'd1;                  //读使能拉高，即一直读ROM数据
assign 	rom_addr = ((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT)) ? rom_addr_pic:rom_addr_buffer;
assign	rd_en_all = ((pixel_xpos >= PIC_X_START - 3'd6 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 3'd6 + PIC_X_DIVIDE) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT - 3'd4)) ? 1'b1:1'b0; 	
assign	rst_fifo = 	(pixel_ypos == PIC_Y_START + PIC_HEIGHT - 3'd4 && pixel_xpos == PIC_X_START + PIC_WIDTH + PIC_X_DIVIDE) ? 1'b0:1'b1;			

//根据当前像素点坐标指定当前像素点颜色数据
always @(posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_data <= WHITE;
    else 
		begin
			if((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
				&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT))
				pixel_data <= rom_rd_data;  //显示图片
			else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 3'd4)) 
				&& (pixel_xpos >= PIC_X_START + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + (PIC_WIDTH - 3'd4) + PIC_X_DIVIDE)) 
				pixel_data <= matrix_dout;
			else
				pixel_data <= WHITE;    
		end  
end

//根据当前扫描点的横纵坐标为ROM地址(图片)赋值
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

//cnt_buffer累加对预读像素点计数
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		cnt_buffer <= 10'd0;
	else if(pixel_ypos <= PIC_Y_START && cnt_buffer < PRE_READ_NUM && !fifo_rst_busy)	
		cnt_buffer <= cnt_buffer + 1'd1;
	else if(!rst_fifo)
		cnt_buffer <= 10'd0;
	else
		cnt_buffer <= cnt_buffer;
end

//根据当前扫描点的横纵坐标为ROM地址(行缓存)赋值
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_buffer <= 16'd0;
	else if(pixel_ypos <= PIC_Y_START && cnt_buffer < PRE_READ_NUM && !fifo_rst_busy)
		rom_addr_buffer <= rom_addr_buffer + 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 3'd5)) 
			&& (pixel_xpos >= PIC_X_START - 3'd7 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 3'd7 + PIC_X_DIVIDE)) 
        rom_addr_buffer <= rom_addr_buffer + 1'd1;
    else if(!rst_fifo)
        rom_addr_buffer <= 16'd0;
	else
		rom_addr_buffer <= rom_addr_buffer;
end

//fifo允许输入逻辑判断
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		buffer_valid_in <= 1'd0;
	else if(pixel_ypos <= PIC_Y_START && cnt_buffer < PRE_READ_NUM && !fifo_rst_busy)
		buffer_valid_in <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 3'd5)) 
			&& (pixel_xpos >= PIC_X_START - 3'd7 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 3'd7 + PIC_X_DIVIDE)) 
		buffer_valid_in <= 1'd1;
	else
		buffer_valid_in <= 1'd0;
end

//矩阵允许输入判断
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		matrix_valid_in <= 1'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 3'd4)) 
			&& (pixel_xpos >= PIC_X_START - 3'd7 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 3'd7 + PIC_X_DIVIDE)) 
		matrix_valid_in <= 1'd1;
	else
		matrix_valid_in <= 1'd0;
end

//ROM：存储图片
blk_mem_gen_0  blk_mem_gen_0 
(
	.clka  (lcd_pclk),    // input wire clka
	.ena   (rom_rd_en),   // input wire ena
	.addra (rom_addr),    // input wire [18 : 0] addra
	.douta (rom_rd_data)  // output wire [23 : 0] douta
);

//fifo行缓存
line_buffer u_line_buffer
(
	.clk            (lcd_pclk			),
	.rst_n          (rst_n				),
	.rst_fifo		(rst_fifo			),
	.din            (rom_rd_data		),
	.dout1          (buffer_dout1		),
	.dout2          (buffer_dout2		),
	.dout3          (buffer_dout3		),
	.dout4          (buffer_dout4		),
	.dout5          (buffer_dout5		),
	.rd_en_all		(rd_en_all			),
	.fifo_rst_busy	(fifo_rst_busy		),
	.valid_in       (buffer_valid_in	)
);
 
//5×5矩阵
matrix_5x5 u_matrix_5x5
(
	.clk  			(lcd_pclk		),
	.rst_n          (rst_n			),
	.valid_in       (matrix_valid_in),
	.din1           (buffer_dout1	),
	.din2           (buffer_dout2	),
	.din3           (buffer_dout3	),
	.din4           (buffer_dout4	),
	.din5           (buffer_dout5	),
	.dout           (matrix_dout	)
); 
 
endmodule
