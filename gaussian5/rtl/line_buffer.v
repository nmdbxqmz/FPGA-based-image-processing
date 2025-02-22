module line_buffer 
(
	clk,
	rst_n,
	rst_fifo,
	din,
	dout1,
	dout2,
	dout3,
	dout4,
	dout5,
	rd_en_all,
	fifo_rst_busy,
	valid_in
);

//port define
input  				clk;
input  				rst_n;
input  				rst_fifo;		//fifo复位信号
input  [WIDTH-1:0] 	din;			//u_line_fifo1输入
output [WIDTH-1:0] 	dout1;			//u_line_fifo1输出
output [WIDTH-1:0] 	dout2;			//u_line_fifo2输出
output [WIDTH-1:0] 	dout3;			//u_line_fifo3输出
output [WIDTH-1:0] 	dout4;			//u_line_fifo4输出
output [WIDTH-1:0] 	dout5;			//u_line_fifo5输出
input				rd_en_all;		//fifo总输出允许信号
output				fifo_rst_busy;	//fifo复位繁忙信号
input  				valid_in;		//输入数据有效，写使能

//reg define
reg    [8:0] cnt1;			//u_line_fifo1写计数器
reg    [8:0] cnt2;          //u_line_fifo2写计数器
reg    [8:0] cnt3;			//u_line_fifo3写计数器
reg    [8:0] cnt4;          //u_line_fifo4写计数器

//wire define
wire   rd_en1;				//u_line_fifo2读允许信号
wire   rd_en2;              //u_line_fifo3读允许信号
wire   rd_en3;				//u_line_fifo4读允许信号
wire   rd_en4;              //u_line_fifo5读允许信号

//*****************************************************
//**                    main code
//*****************************************************
assign rd_en1 = ((cnt1 >= PIC_WIDTH && valid_in) || rd_en_all) ? 1'b1:1'b0;
assign rd_en2 = ((cnt2 >= PIC_WIDTH && valid_in) || rd_en_all) ? 1'b1:1'b0;
assign rd_en3 = ((cnt3 >= PIC_WIDTH && valid_in) || rd_en_all) ? 1'b1:1'b0;
assign rd_en4 = ((cnt4 >= PIC_WIDTH && valid_in) || rd_en_all) ? 1'b1:1'b0;

//cnt1计数
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        cnt1 <= 9'b0;
	else if(!rst_fifo)
		cnt1 <= 9'b0;
    else if(valid_in)
		begin
			if(cnt1 >= PIC_WIDTH)
				cnt1 <= PIC_WIDTH;
			else
				cnt1 <= cnt1 +1'b1;
		end
    else
        cnt1 <= cnt1;
end

//cnt2计数
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        cnt2 <= 9'b0;
	else if(!rst_fifo)
		cnt2 <= 9'b0;
    else if(valid_in && cnt1 >= PIC_WIDTH)
		begin
			if(cnt2 >= PIC_WIDTH)
				cnt2 <= PIC_WIDTH;
			else
				cnt2 <= cnt2 +1'b1;
		end
    else
        cnt2 <= cnt2;
end

//cnt3计数
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        cnt3 <= 9'b0;
	else if(!rst_fifo)
		cnt3 <= 9'b0;
    else if(valid_in && cnt2 >= PIC_WIDTH)
		begin
			if(cnt3 >= PIC_WIDTH)
				cnt3 <= PIC_WIDTH;
			else
				cnt3 <= cnt3 +1'b1;
		end
    else
        cnt3 <= cnt3;
end

//cnt4计数
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        cnt4 <= 9'b0;
	else if(!rst_fifo)
		cnt4 <= 9'b0;
    else if(valid_in && cnt3 >= PIC_WIDTH)
		begin
			if(cnt4 >= PIC_WIDTH)
				cnt4 <= PIC_WIDTH;
			else
				cnt4 <= cnt4 +1'b1;
		end
    else
        cnt4 <= cnt4;
end

//fifo核例化
fifo_generator_0 u_line_fifo1
(
    .clk 			(clk			),
    .rst 			(!rst_fifo		),
    .din 			(din			),
    .wr_en 			(valid_in		),
    .rd_en 			(rd_en1			),
    .dout			(dout1			),

    .empty			(				),
    .full			(				),  
    .wr_rst_busy	(fifo_rst_busy	),  
    .rd_rst_busy	(				)
);

fifo_generator_0 u_line_fifo2
(
    .clk 			(clk			),
    .rst 			(!rst_fifo		),
    .din 			(dout1			),
    .wr_en 			(rd_en1			),
    .rd_en 			(rd_en2			),
    .dout			(dout2			),

    .empty			(				),
    .full			(				),  
    .wr_rst_busy	(				),  
    .rd_rst_busy	(				)
);

fifo_generator_0 u_line_fifo3
(
    .clk 			(clk			),
    .rst 			(!rst_fifo		),
    .din 			(dout2			),
    .wr_en 			(rd_en2			),
    .rd_en 			(rd_en3			),
    .dout			(dout3			),

    .empty			(				),
    .full			(				),  
    .wr_rst_busy	(				),  
    .rd_rst_busy	(				)
);

fifo_generator_0 u_line_fifo4
(
    .clk 			(clk			),
    .rst 			(!rst_fifo		),
    .din 			(dout3			),
    .wr_en 			(rd_en3			),
    .rd_en 			(rd_en4			),
    .dout			(dout4			),

    .empty			(				),
    .full			(				),  
    .wr_rst_busy	(				),  
    .rd_rst_busy	(				)
);

fifo_generator_0 u_line_fifo5
(
    .clk 			(clk			),
    .rst 			(!rst_fifo		),
    .din 			(dout4			),
    .wr_en 			(rd_en4			),
    .rd_en 			(rd_en_all		),
    .dout			(dout5			),

    .empty			(				),
    .full			(				),  
    .wr_rst_busy	(				),  
    .rd_rst_busy	(				)
);

endmodule

