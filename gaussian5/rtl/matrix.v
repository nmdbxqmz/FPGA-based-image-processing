module matrix_5x5 
(
    clk,
    rst_n,
    valid_in,
    din1,
    din2,
	din3,
	din4,
	din5,
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
input      [WIDTH-1:0] din4;
input      [WIDTH-1:0] din5;
output reg [WIDTH-1:0] dout;

//reg define
reg [WIDTH-1:0] din1_1;
reg [WIDTH-1:0] din1_2;
reg [WIDTH-1:0] din1_3;
reg [WIDTH-1:0] din1_4;
reg [WIDTH-1:0] din1_5;
reg [WIDTH-1:0] din2_1;
reg [WIDTH-1:0] din2_2;
reg [WIDTH-1:0] din2_3;
reg [WIDTH-1:0] din2_4;
reg [WIDTH-1:0] din2_5;
reg [WIDTH-1:0] din3_1;
reg [WIDTH-1:0] din3_2;
reg [WIDTH-1:0] din3_3;
reg [WIDTH-1:0] din3_4;
reg [WIDTH-1:0] din3_5;
reg [WIDTH-1:0] din4_1;
reg [WIDTH-1:0] din4_2;
reg [WIDTH-1:0] din4_3;
reg [WIDTH-1:0] din4_4;
reg [WIDTH-1:0] din4_5;
reg [WIDTH-1:0] din5_1;
reg [WIDTH-1:0] din5_2;
reg [WIDTH-1:0] din5_3;
reg [WIDTH-1:0] din5_4;
reg [WIDTH-1:0] din5_5;
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
			 din1_4 <= 24'b0;
			 din1_5 <= 24'b0;
			 
			 din2_1 <= 24'b0;
			 din2_2 <= 24'b0;
			 din2_3 <= 24'b0;
			 din2_4 <= 24'b0;
			 din2_5 <= 24'b0;
			 
			 din3_1 <= 24'b0;
			 din3_2 <= 24'b0;
			 din3_3 <= 24'b0;
			 din3_4 <= 24'b0;
			 din3_5 <= 24'b0;
			 
			 din4_1 <= 24'b0;
			 din4_2 <= 24'b0;
			 din4_3 <= 24'b0;
			 din4_4 <= 24'b0;
			 din4_5 <= 24'b0;
			 
			 din5_1 <= 24'b0;
			 din5_2 <= 24'b0;
			 din5_3 <= 24'b0;
			 din5_4 <= 24'b0;
			 din5_5 <= 24'b0;
		 end
	else if(valid_in) 
		 begin 
			 din1_1 <= din1;
			 din1_2 <= din1_1;
			 din1_3 <= din1_2;
			 din1_4 <= din1_3;
			 din1_5 <= din1_4;
			 
			 din2_1 <= din2;
			 din2_2 <= din2_1;
			 din2_3 <= din2_2;
			 din2_4 <= din2_3;
			 din2_4 <= din2_4;
			 
			 din3_1 <= din3;
			 din3_2 <= din3_1;
			 din3_3 <= din3_2; 
			 din3_4 <= din3_3; 
			 din3_5 <= din3_4; 
			 
			 din4_1 <= din4;
			 din4_2 <= din4_1;
			 din4_3 <= din4_2; 
			 din4_4 <= din4_3; 
			 din4_5 <= din4_4; 
			 
			 din5_1 <= din5;
			 din5_2 <= din5_1;
			 din5_3 <= din5_2; 
			 din5_4 <= din5_3; 
			 din5_5 <= din5_4; 
		 end
	else
		begin
			din1_1 <= din1_1;
			din1_2 <= din1_2;
			din1_3 <= din1_3;
			din1_4 <= din1_4;
			din1_5 <= din1_5;
			
			din2_1 <= din2_1;
			din2_2 <= din2_2;
			din2_3 <= din2_3;
			din2_4 <= din2_4;
			din2_5 <= din2_5;
			
			din3_1 <= din3_1;
			din3_2 <= din3_2;
			din3_3 <= din3_3;
			din3_4 <= din3_4;
			din3_5 <= din3_5;
			
			din4_1 <= din4_1;
			din4_2 <= din4_2;
			din4_3 <= din4_3;
			din4_4 <= din4_4;
			din4_5 <= din4_5;
			
			din5_1 <= din5_1;
			din5_2 <= din5_2;
			din5_3 <= din5_3;
			din5_4 <= din5_4;
			din5_5 <= din5_5;
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
			R <= 8'd0;
			G <= 8'd0;
			B <= 8'd0;
		end
	else if(valid_in)
		begin
			B <= (1*din1_1[7:0] + 4*din1_2[7:0] + 7*din1_3[7:0] + 4*din1_4[7:0] + 1*din1_5[7:0] + 
			      4*din2_1[7:0] + 16*din2_2[7:0] + 26*din2_3[7:0] + 16*din2_4[7:0] + 4*din2_5[7:0] +
				  7*din3_1[7:0] + 26*din3_2[7:0] + 41*din3_3[7:0] + 26*din3_4[7:0] + 7*din3_5[7:0] +
				  4*din4_1[7:0] + 16*din4_2[7:0] + 26*din4_3[7:0] + 16*din4_4[7:0] + 4*din4_5[7:0] +
				  1*din5_1[7:0] + 4*din5_2[7:0] + 7*din5_3[7:0] + 4*din5_4[7:0] + 1*din5_5[7:0]) / 273;
				  
			G <= (1*din1_1[15:8] + 4*din1_2[15:8] + 7*din1_3[15:8] + 4*din1_4[15:8] + 1*din1_5[15:8] + 
			      4*din2_1[15:8] + 16*din2_2[15:8] + 26*din2_3[15:8] + 16*din2_4[15:8] + 4*din2_5[15:8] +
				  7*din3_1[15:8] + 26*din3_2[15:8] + 41*din3_3[15:8] + 26*din3_4[15:8] + 7*din3_5[15:8] +
				  4*din4_1[15:8] + 16*din4_2[15:8] + 26*din4_3[15:8] + 16*din4_4[15:8] + 4*din4_5[15:8] +
				  1*din5_1[15:8] + 4*din5_2[15:8] + 7*din5_3[15:8] + 4*din5_4[15:8] + 1*din5_5[15:8]) / 273;
				  
			R <= (1*din1_1[23:16] + 4*din1_2[23:16] + 7*din1_3[23:16] + 4*din1_4[23:16] + 1*din1_5[23:16] + 
			      4*din2_1[23:16] + 16*din2_2[23:16] + 26*din2_3[23:16] + 16*din2_4[23:16] + 4*din2_5[23:16] +
				  7*din3_1[23:16] + 26*din3_2[23:16] + 41*din3_3[23:16] + 26*din3_4[23:16] + 7*din3_5[23:16] +
				  4*din4_1[23:16] + 16*din4_2[23:16] + 26*din4_3[23:16] + 16*din4_4[23:16] + 4*din4_5[23:16] +
				  1*din5_1[23:16] + 4*din5_2[23:16] + 7*din5_3[23:16] + 4*din5_4[23:16] + 1*din5_5[23:16]) / 273;
				  
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
