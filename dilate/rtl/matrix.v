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

//port define
input 				   clk;
input 				   rst_n;
input 				   valid_in;
input 	   [WIDTH-1:0] din1;
input 	   [WIDTH-1:0] din2;
input      [WIDTH-1:0] din3;
output reg [WIDTH-1:0] dout;

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
reg [WIDTH-1:0]	max;

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
		 begin //像素有效信号
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
			if(cnt < PIC_WIDTH)
				cnt <= cnt + 9'd1;
			else if(cnt >= (PIC_WIDTH + 9'd1))
				cnt <= 9'd0;
			else
				cnt <= cnt;
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
			max <= 24'd0;
		end
	else if(valid_in)
		begin
			if(din2_1 >= din1_2 && din2_1 >= din2_2 && din2_1 >= din3_2 && din2_1 >= din2_3)
				max <= din2_1;
			else if(din2_2 >= din1_2 && din2_2 >= din2_1 && din2_2 >= din3_2 && din2_2 >= din2_3)
				max <= din2_2;
			else if(din2_3 >= din1_2 && din2_3 >= din2_1 && din2_3 >= din3_2 && din2_3 >= din2_2)
				max <= din2_3;
			else if(din1_2 >= din2_2 && din1_2 >= din2_1 && din1_2 >= din3_2 && din1_2 >= din2_3)
				max <= din1_2;
			else
				max <= din3_2;
			
			dout <= max;
		end
	else	 
		begin
			dout <= dout;
			max <= max;
		end
end

endmodule
