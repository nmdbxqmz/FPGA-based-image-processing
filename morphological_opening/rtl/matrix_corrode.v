module matrix_corrode 
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

//port define
input 				   clk;
input 				   rst_n;
input 				   valid_in;
input 	   [WIDTH-1:0] din1;
input 	   [WIDTH-1:0] din2;
input      [WIDTH-1:0] din3;
output reg  		   valid_out;
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
reg [WIDTH-1:0]	min;


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
			if(cnt < PIC_WIDTH)
				cnt <= cnt + 9'd1;
			else if(cnt >= (PIC_WIDTH + 9'd1))
				cnt <= 9'd0;
			else
				cnt <= cnt;
		end
	else	
		cnt <= cnt;
end

//矩阵允许输出判断
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		valid_out <= 1'd0;
	else if(valid_in && (cnt > 9'd3))
		valid_out <= 1'd1;
	else
		valid_out <= 1'd0;
end

//矩阵计算
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		begin	
			dout <= 24'd0;
			min <= 24'd0;
		end
	else if(valid_in && (cnt > 9'd2))
		begin
			if(din2_1 <= din1_2 && din2_1 <= din2_2 && din2_1 <= din3_2 && din2_1 <= din2_3)
				min <= din2_1;
			else if(din2_2 <= din1_2 && din2_2 <= din2_1 && din2_2 <= din3_2 && din2_2 <= din2_3)
				min <= din2_2;
			else if(din2_3 <= din1_2 && din2_3 <= din2_1 && din2_3 <= din3_2 && din2_3 <= din2_2)
				min <= din2_3;
			else if(din1_2 <= din2_2 && din1_2 <= din2_1 && din1_2 <= din3_2 && din1_2 <= din2_3)
				min <= din1_2;
			else
				min <= din3_2;
			
			dout <= min;
		end
	else	 
		begin
			dout <= dout;
			min <= min;
		end
end

endmodule
