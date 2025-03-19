module matrix_suppression
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
parameter  H_THRESHOLD  = 8'd90;	  //高阈值
parameter  L_THRESHOLD  = 8'd45;	  //低阈值

//port define
input 				   clk;
input 				   rst_n;
input 				   valid_in;
input 	   [WIDTH-1:0] din1;
input 	   [WIDTH-1:0] din2;
input      [WIDTH-1:0] din3;
output   		       valid_out;
output reg [WIDTH-3:0] dout;

//reg define
reg [WIDTH-1:0] din1_1;
reg [WIDTH-1:0] din1_2;
reg [WIDTH-1:0] din1_3;
reg [WIDTH-1:0] din2_1;
reg [WIDTH-1:0] din2_2;
reg [WIDTH-1:0] din2_3;
reg [WIDTH-1:0] din3_1;
reg [WIDTH-1:0] din3_2;
reg [WIDTH-1:0] din3_3;
reg [8:0]		cnt;
reg [WIDTH-3:0]	suppression;

//矩阵输出允许判断
assign valid_out = (cnt != 9'd0 && cnt != 9'd1 && cnt != 9'd2 && cnt != 9'd3 && cnt != 9'd4 && cnt != 9'd5) ? 1'd1:1'd0;

//数据存入
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
		 begin
			 din1_1 <=10'b0;
			 din1_2 <=10'b0;
			 din1_3 <=10'b0;
			          
			 din2_1 <=10'b0;
			 din2_2 <=10'b0;
			 din2_3 <=10'b0;
			          
			 din3_1 <=10'b0;
			 din3_2 <=10'b0;
			 din3_3 <=10'b0;
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
			dout <= 8'd0;
			suppression <= 8'd0;
		end
	else if(valid_in)
		begin
			if(din2_2[1:0] == 2'd0)
				begin
					if(din2_2[9:2] >= din1_2[9:2] && din2_2[9:2] >= din3_2[9:2])
						begin
							if(din2_2[9:2] >= H_THRESHOLD)
								suppression <= 8'd255;
							else if(din2_2[9:2] <= L_THRESHOLD)
								suppression <= 8'd0;
							else
								suppression <= din2_2[9:2];
						end
					else
						suppression <= 8'd0;
				end
			else if(din2_2[1:0] == 2'd1)
				begin
					if(din2_2[9:2] >= din1_1[9:2] && din2_2[9:2] >= din3_3[9:2])
						begin
							if(din2_2[9:2] >= H_THRESHOLD)
								suppression <= 8'd255;
							else if(din2_2[9:2] <= L_THRESHOLD)
								suppression <= 8'd0;
							else
								suppression <= din2_2[9:2];
						end
					else
						suppression <= 8'd0;
				end
			else if(din2_2[1:0] == 2'd2)
				begin
					if(din2_2[9:2] >= din2_1[9:2] && din2_2[9:2] >= din2_3[9:2])
						begin
							if(din2_2[9:2] >= H_THRESHOLD)
								suppression <= 8'd255;
							else if(din2_2[9:2] <= L_THRESHOLD)
								suppression <= 8'd0;
							else
								suppression <= din2_2[9:2];
						end
					else
						suppression <= 8'd0;
				end
			else
				begin
					if(din2_2[9:2] >= din1_3[9:2] && din2_2[9:2] >= din3_1[9:2])
						begin
							if(din2_2[9:2] >= H_THRESHOLD)
								suppression <= 8'd255;
							else if(din2_2[9:2] <= L_THRESHOLD)
								suppression <= 8'd0;
							else
								suppression <= din2_2[9:2];
						end
					else
						suppression <= 8'd0;
				end
			dout <= suppression;
		end
	else	 
		begin
			dout <= dout;
			suppression <= suppression;
		end
end

endmodule
