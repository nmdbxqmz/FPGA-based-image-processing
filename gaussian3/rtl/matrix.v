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
reg [7:0]		R;
reg [7:0]		G;
reg [7:0]		B;

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

//矩阵计算
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		begin	
			dout <= 24'd0;
			R <= 8'd0;
			G <= 8'd0;
			B <= 8'd0;
		end
	else if(valid_in && (cnt > 9'd2))
		begin
			B <= (1*din1_1[7:0] + 2*din1_2[7:0] + 1*din1_3[7:0] + 2*din2_1[7:0] + 4*din2_2[7:0] + 2*din2_3[7:0] + 1*din3_1[7:0] + 2*din3_2[7:0] + 1*din3_3[7:0]) / 16;
			G <= (1*din1_1[15:8] + 2*din1_2[15:8] + 1*din1_3[15:8] + 2*din2_1[15:8] + 4*din2_2[15:8] + 2*din2_3[15:8] + 1*din3_1[15:8] + 2*din3_2[15:8] + 1*din3_3[15:8]) / 16;
			R <= (1*din1_1[23:16] + 2*din1_2[23:16] + 1*din1_3[23:16] + 2*din2_1[23:16] + 4*din2_2[23:16] + 2*din2_3[23:16] + 1*din3_1[23:16] + 2*din3_2[23:16] + 1*din3_3[23:16]) / 16;
			dout <= {R, G, B};
		end
	else	 
		begin
			dout <= dout;
			B <= B;
			G <= G;
			R <= R;
		end
end

endmodule
