module matrix_sobel
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
reg [7:0]		GX;
reg [7:0]		GY;

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
			if(cnt < PIC_WIDTH - 11'd1)
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
			GX <= 8'd0;
			GY <= 8'd0;
		end
	else if(valid_in)
		begin
			GX <= (1*din1_1 + 2*din2_1 + 1*din3_1) - (1*din1_3 + 2*din2_3 + 1*din3_3);
			GY <= (1*din1_1 + 2*din1_2 + 1*din1_3) - (1*din3_1 + 2*din3_2 + 1*din3_3);
			if (GX >= 8'd0 && GY >= 8'd0)
				begin
					if((GX + GY) > 8'd255)
						dout <= 8'd255;
					else
						dout <= {GX + GY};
				end
			else if(GX >= 8'd0 && GY < 8'd0)
				begin
					if((GX - GY) > 8'd255)
						dout <= 8'd255;
					else
						dout <= {GX - GY};
				end
			else if(GX < 8'd0 && GY >= 8'd0)
				begin
					if((GY - GX) > 8'd255)
						dout <= 8'd255;
					else
						dout <= {GY - GX};
				end
			else
				begin
					if((- GX - GY) > 8'd255)
						dout <= 8'd255;
					else
						dout <= {- GX - GY};
				end

		end
	else
		begin
			dout <= dout;
			GX <= GX;
			GY <= GY;
		end
end

endmodule
