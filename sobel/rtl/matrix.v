module matrix_3x3 
(
    clk,
    rst_n,
    valid_in,
    din1,
    din2,
	din3,
    dout
);

//parameter define     
parameter  PIC_WIDTH    = 11'd250;    //图片宽度
parameter  WIDTH 		= 24;		  //数据位宽

//port define
input 				   clk;
input 				   rst_n;
input 				   valid_in;
input 	   [WIDTH-1:0] din1;
input 	   [WIDTH-1:0] din2;
input      [WIDTH-1:0] din3;
output reg [WIDTH-1:0] dout;

//reg define
reg 		[WIDTH-1:0] din1_1;
reg 		[WIDTH-1:0] din1_2;
reg 		[WIDTH-1:0] din1_3;
reg 		[WIDTH-1:0] din2_1;
reg 		[WIDTH-1:0] din2_2;
reg 		[WIDTH-1:0] din2_3;
reg 		[WIDTH-1:0] din3_1;
reg 		[WIDTH-1:0] din3_2;
reg 		[WIDTH-1:0] din3_3;
reg 		[8:0]		cnt;
reg signed 	[12:0]		GX;
reg signed 	[12:0]		GY;
reg signed 	[12:0]		sobel1;
reg signed 	[12:0]		sobel2;
reg signed 	[12:0]		sobel3;
reg signed 	[12:0]		sobel4;
reg	signed	[12:0]		standard;

//初始化
initial
begin
	standard <= 13'd0;
end

//数据存入
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
		 begin
			 din1_1 <= 24'b0;
			 din1_2 <= 24'b0;
			 din1_3 <= 24'b0;
			 
			 din2_1 <= 24'b0;
			 din2_2 <= 24'b0;
			 din2_3 <= 24'b0;
			 
			 din3_1 <= 24'b0;
			 din3_2 <= 24'b0;
			 din3_3 <= 24'b0;
		 end
	else if(valid_in) 
		 begin 
			 din1_1 <= din1;
			 din1_2 <= din1_1;
			 din1_3 <= din1_2;
			 
			 din2_1 <= din2;
			 din2_2 <= din2_1;
			 din2_3 <= din2_2;
			 
			 din3_1 <= din3;
			 din3_2 <= din3_1;
			 din3_3 <= din3_2; 
		 end
	else
		begin
			din1_1 <= din1_1;
			din1_2 <= din1_2;
			din1_3 <= din1_3;
			
			din2_1 <= din2_1;
			din2_2 <= din2_2;
			din2_3 <= din2_3;
			
			din3_1 <= din3_1;
			din3_2 <= din3_2;
			din3_3 <= din3_3; 
		end
end

//行计数
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		cnt <= 9'd0;
	else if(valid_in)
		begin
			if(cnt < (PIC_WIDTH - 11'd1))
				cnt <= cnt + 9'd1;
			else
				cnt <= 9'd0;
		end
	else	
		cnt <= 9'd0;
end

//矩阵计算
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		begin	
			dout <= 24'd0;
			GX <= 13'd0;
			GY <= 13'd0;
			sobel1 <= 13'd0;
			sobel2 <= 13'd0;
			sobel3 <= 13'd0;
			sobel4 <= 13'd0;
		end
	else if(valid_in)
		begin			//这里sobel1、2、3、4各计算一次是用来取sobel的绝对值，方便dout的截位操作
			sobel1 <= ((din1_1[7:0] + 2*din2_1[7:0] + din3_1[7:0]) - (din1_3[7:0] + 2*din2_3[7:0] + din3_3[7:0])) + ((din1_1[7:0] + 2*din1_2[7:0] + din2_3[7:0]) - (din3_1[7:0] + 2*din3_2[7:0] + din3_3[7:0]));
			sobel2 <= ((din1_1[7:0] + 2*din2_1[7:0] + din3_1[7:0]) - (din1_3[7:0] + 2*din2_3[7:0] + din3_3[7:0])) + ((din3_1[7:0] + 2*din3_2[7:0] + din3_3[7:0]) - (din1_1[7:0] + 2*din1_2[7:0] + din2_3[7:0]));
			sobel3 <= ((din1_3[7:0] + 2*din2_3[7:0] + din3_3[7:0]) - (din1_1[7:0] + 2*din2_1[7:0] + din3_1[7:0])) + ((din1_1[7:0] + 2*din1_2[7:0] + din2_3[7:0]) - (din3_1[7:0] + 2*din3_2[7:0] + din3_3[7:0]));
			sobel4 <= ((din1_3[7:0] + 2*din2_3[7:0] + din3_3[7:0]) - (din1_1[7:0] + 2*din2_1[7:0] + din3_1[7:0])) + ((din3_1[7:0] + 2*din3_2[7:0] + din3_3[7:0]) - (din1_1[7:0] + 2*din1_2[7:0] + din2_3[7:0]));
			GX <= (din1_1[7:0] + 2*din2_1[7:0] + din3_1[7:0]) - (din1_3[7:0] + 2*din2_3[7:0] + din3_3[7:0]);                                                  
			GY <= (din1_1[7:0] + 2*din1_2[7:0] + din2_3[7:0]) - (din3_1[7:0] + 2*din3_2[7:0] + din3_3[7:0]);
			if(GX >= standard && GY >= standard)
				begin
					if(sobel1 >= 13'd255)
						dout <= 24'hffffff;
					else
						dout <= {3{sobel1[7:0]}};
				end
			else if(GX >= standard && GY < standard)
				begin
					if(sobel2 >= 13'd255)
						dout <= 24'hffffff;
					else
						dout <= {3{sobel2[7:0]}};
				end
			else if(GX < standard && GY >= standard)
				begin
					if(sobel3 >= 13'd255)
						dout <= 24'hffffff;
					else
						dout <= {3{sobel3[7:0]}};
				end
			else
				begin
					if(sobel4 >= 13'd255)
						dout <= 24'hffffff;
					else
						dout <= {3{sobel4[7:0]}};
				end
		end
	else
		begin
			dout <= dout;
			GX <= GX;
			GY <= GY;
			sobel1 <= sobel1;
			sobel2 <= sobel2;
			sobel3 <= sobel3;
			sobel4 <= sobel4;
		end
end

endmodule
