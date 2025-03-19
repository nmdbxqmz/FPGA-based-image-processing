module matrix_threshold
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
parameter  WIDTH 		= 8;		  //数据位宽

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
reg [WIDTH-1:0]	threshold;


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
			dout <= 8'd0;
			threshold <= 8'd0;
		end
	else if(valid_in)
		begin
			if(din2_2 != 8'd255 && din2_2 != 8'd0)
				begin
					if(din1_1 == 8'd255 || din1_2 == 8'd255 || din1_3 == 8'd255 ||din2_1 == 8'd255|| din2_3 == 8'd255 || din3_1 == 8'd255 || din3_2 == 8'd255 || din3_3 == 8'd255)
						threshold <= 8'd255;
					else
						threshold <= 8'd0;
				end
			else
				threshold <= din2_2;
			dout <= threshold;
		end
	else	 
		begin
			dout <= dout;
			threshold <= threshold;
		end
end

endmodule
