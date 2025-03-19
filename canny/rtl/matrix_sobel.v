module matrix_sobel
(
    clk,
    rst_n,
    valid_in,
    din1,
    din2,
	din3,
	valid_out,
    dout
);

//parameter define 
parameter  PIC_WIDTH    = 11'd250;    //图片宽度
parameter  WIDTH 		= 8;		  //数据位宽

//port define
input 				   clk;
input 				   rst_n;
input 				   valid_in;
input 	   [WIDTH-1:0] din1;
input 	   [WIDTH-1:0] din2;
input      [WIDTH-1:0] din3;
output   		       valid_out;
output reg [WIDTH+1:0] dout;

//reg define
reg 	   [WIDTH-1:0] 	din1_1;
reg 	   [WIDTH-1:0] 	din1_2;
reg 	   [WIDTH-1:0] 	din1_3;
reg 	   [WIDTH-1:0] 	din2_1;
reg 	   [WIDTH-1:0] 	din2_2;
reg 	   [WIDTH-1:0] 	din2_3;
reg 	   [WIDTH-1:0] 	din3_1;
reg 	   [WIDTH-1:0] 	din3_2;
reg 	   [WIDTH-1:0] 	din3_3;
reg 	   [8:0]		cnt;
reg signed [12:0]		GX;
reg signed [12:0]		GY;
reg signed [12:0]		sobel1;
reg signed [12:0]		sobel2;
reg signed [12:0]		sobel3;
reg signed [12:0]		sobel4;

//矩阵输出允许判断
assign valid_out = (cnt != 9'd1 && cnt != 9'd2 && cnt != 9'd3 && cnt != 9'd4) ? 1'd1:1'd0;

//数据存入
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
		 begin
			 din1_1 <= 8'b0;
			 din1_2 <= 8'b0;
			 din1_3 <= 8'b0;
			           
			 din2_1 <= 8'b0;
			 din2_2 <= 8'b0;
			 din2_3 <= 8'b0;
			        
			 din3_1 <= 8'b0;
			 din3_2 <= 8'b0;
			 din3_3 <= 8'b0;
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
			dout <= 10'd0;
			GX <= 13'd0;
			GY <= 13'd0;
			sobel1 <= 13'd0;
			sobel2 <= 13'd0;
			sobel3 <= 13'd0;
			sobel4 <= 13'd0;
		end
	else if(valid_in)
		begin
			sobel1 <= ((din1_1 + 2*din2_1 + din3_1) - (din1_3 + 2*din2_3 + din3_3)) + ((din1_1 + 2*din1_2 + din2_3) - (din3_1 + 2*din3_2 + din3_3));
			sobel2 <= ((din1_1 + 2*din2_1 + din3_1) - (din1_3 + 2*din2_3 + din3_3)) + ((din3_1 + 2*din3_2 + din3_3) - (din1_1 + 2*din1_2 + din2_3));
			sobel3 <= ((din1_3 + 2*din2_3 + din3_3) - (din1_1 + 2*din2_1 + din3_1)) + ((din1_1 + 2*din1_2 + din2_3) - (din3_1 + 2*din3_2 + din3_3));
			sobel4 <= ((din1_3 + 2*din2_3 + din3_3) - (din1_1 + 2*din2_1 + din3_1)) + ((din3_1 + 2*din3_2 + din3_3) - (din1_1 + 2*din1_2 + din2_3));
			GX <= (din1_1 + 2*din2_1 + din3_1) - (din1_3 + 2*din2_3 + din3_3);
			GY <= (din1_1 + 2*din1_2 + din2_3) - (din3_1 + 2*din3_2 + din3_3);
			if(sobel1 >= sobel2 && sobel1 >= sobel3 && sobel1 >= sobel4)
				begin
					if(sobel1 >= 13'd255)
						begin
							if((((GY*57) << 8) / GX) < 9'd53)
								dout <= {8'd255,2'd0};
							else if((((GY*57) << 8) / GX) < 9'd309)
								dout <= {8'd255,2'd1};
							else	
								dout <= {8'd255,2'd2};
						end
					else
						begin
							if((((GY*57) << 8) / GX) < 9'd53)
								dout <= {{sobel1[7:0]},2'd0};
							else if((((GY*57) << 8) / GX) < 9'd309)
								dout <= {{sobel1[7:0]},2'd1};
							else	
								dout <= {{sobel1[7:0]},2'd2};
						end
				end
			else if(sobel2 >= sobel1 && sobel2 >= sobel3 && sobel2 >= sobel4)
				begin
					if(sobel2 >= 13'd255)
						begin
							if(((((-GY)*57) << 8) / GX) < 9'd53)
								dout <= {8'd255,2'd0};
							else if((((-GY) << 8) / GX) < 9'd309)
								dout <= {8'd255,2'd3};
							else	
								dout <= {8'd255,2'd2};
						end
					else
						begin
							if(((((-GY)*57) << 8) / GX) < 9'd53)
								dout <= {{sobel2[7:0]},2'd0};
							else if(((((-GY)*57) << 8) / GX) < 9'd309)
								dout <= {{sobel2[7:0]},2'd3};
							else	
								dout <= {{sobel2[7:0]},2'd2};
						end
				end
			else if(sobel3 >= sobel1 && sobel3 >= sobel2 && sobel3 >= sobel4)
				begin
					if(sobel3 >= 13'd255)
						begin
							if((((GY*57) << 8) / (-GX)) < 9'd53)
								dout <= {8'd255,2'd0};
							else if((((GY*57) << 8) /(-GX)) < 9'd309)
								dout <= {8'd255,2'd3};
							else	
								dout <= {8'd255,2'd2};
						end
					else
						begin
							if((((GY*57) << 8) / (-GX)) < 9'd53)
								dout <= {{sobel3[7:0]},2'd0};
							else if((((GY*57) << 8) /(-GX)) < 9'd309)
								dout <= {{sobel3[7:0]},2'd3};
							else	
								dout <= {{sobel3[7:0]},2'd2};
						end
				end
			else
				begin
					if(sobel4 > 13'd255)
						begin
							if(((((-GY)*57) << 8) / (-GX)) < 9'd53)
								dout <= {8'd255,2'd0};
							else if(((((-GY)*57) << 8) /(-GX)) < 9'd309)
								dout <= {8'd255,2'd1};
							else	
								dout <= {8'd255,2'd2};
						end
					else
						begin
							if(((((-GY)*57) << 8) / (-GX)) < 9'd53)
								dout <= {{sobel4[7:0]},2'd0};
							else if(((((-GY)*57) << 8) /(-GX)) < 9'd309)
								dout <= {{sobel4[7:0]},2'd1};
							else	
								dout <= {{sobel4[7:0]},2'd2};
						end
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
