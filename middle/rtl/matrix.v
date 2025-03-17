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
reg [WIDTH-1:0] din1_max;
reg [WIDTH-1:0] din1_min;
reg [WIDTH-1:0] din1_mid;
reg [WIDTH-1:0] din2_max;
reg [WIDTH-1:0] din2_min;
reg [WIDTH-1:0] din2_mid;
reg [WIDTH-1:0] din3_max;
reg [WIDTH-1:0] din3_min;
reg [WIDTH-1:0] din3_mid;
reg [WIDTH-1:0] middle;
reg [8:0]		cnt;

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

//找出每次输入的最值与中值
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
		 begin
			din1_max <= 24'd0;
			din1_min <= 24'd0;
			din1_mid <= 24'd0;
			
			din2_max <= 24'd0;
			din2_min <= 24'd0;
			din2_mid <= 24'd0;
			
			din3_max <= 24'd0;
			din3_min <= 24'd0;
			din3_mid <= 24'd0;
		 end
	else if(valid_in)
		begin
			if(din1 <= din2 && din2 <= din3)
				begin
					din1_min <= din1;
					din1_mid <= din2;
					din1_max <= din3;
				end
			else if(din1 <= din3 && din3 <= din2)
				begin
					din1_min <= din1;
					din1_mid <= din3;
					din1_max <= din2;
				end
			else if(din2 <= din1 && din1 <= din3)
				begin
					din1_min <= din2;
					din1_mid <= din1;
					din1_max <= din3;
				end
			else if(din2 <= din3 && din3 <= din1)
				begin
					din1_min <= din2;
					din1_mid <= din3;
					din1_max <= din1;
				end
			else if(din3 <= din1 && din1 <= din2)
				begin
					din1_min <= din3;
					din1_mid <= din1;
					din1_max <= din2;
				end
			else 	
				begin
					din1_min <= din3;
					din1_mid <= din2;
					din1_max <= din1;
				end
				
			din2_min <= din1_min;
			din3_min <= din2_min;
			
			din2_mid <= din1_mid;
			din3_mid <= din2_mid;
			
			din2_max <= din1_max;
			din3_max <= din2_max;
		end
	else
		begin
			din1_min <= din1_min;
			din2_min <= din2_min;
			din3_min <= din3_min;
			
			din1_mid <= din1_mid;
			din2_mid <= din2_mid;
			din3_mid <= din3_mid;
			
			din1_max <= din1_max;
			din2_max <= din2_max;
			din3_max <= din3_max;
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

//矩阵计算（找中值）
always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		begin	
			dout <= 24'd0;
			middle <= 24'd0;
		end
	else if(valid_in)
		begin
			if((din2_max <= din1_min && din1_max <= din2_min) || ((din3_max <= din1_min && din1_max <= din2_min)))
				middle <= din1_mid;
			else if((din1_max <= din2_min && din2_max <= din3_min) || ((din3_max <= din2_min && din2_max <= din1_min)))
				middle <= din2_mid;
			else if((din1_max <= din3_min && din3_max <= din2_min) || ((din2_max <= din3_min && din3_max <= din1_min)))
				middle <= din3_mid;
				
			else if(din2_max <= din1_min && din3_max <= din1_min)
				begin
					if(din2_max <= din3_max)
						middle <= din2_max;
					else 
						middle <= din3_max;
				end
			else if(din1_max <= din2_min && din3_max <= din2_min)
				begin
					if(din1_max <= din3_max)
						middle <= din1_max;
					else 
						middle <= din3_max;
				end
			else if(din1_max <= din3_min && din2_max <= din3_min)
				begin
					if(din1_max <= din2_max)
						middle <= din1_max;
					else 
						middle <= din2_max;
				end
				
			else if(din1_max <= din2_mid && din1_max <= din3_mid)
				begin
					if(din1_max <= din2_min && din1_max <= din3_min)
						middle <= din1_max;
					else if(din2_min <= din3_min && din2_min <= din1_max)
						middle <= din2_min;
					else if(din3_min <= din2_min && din3_min <= din1_max)
						middle <= din3_min;
				end
			else if(din2_max <= din1_mid && din2_max <= din3_mid)
				begin
					if(din2_max <= din1_min && din2_max <= din3_min)
						middle <= din2_max;
					else if(din1_min <= din3_min && din1_min <= din2_max)
						middle <= din1_min;
					else if(din3_min <= din1_min && din3_min <= din2_max)
						middle <= din3_min;
				end
			else if(din3_max <= din1_mid && din3_max <= din2_mid)
				begin
					if(din3_max <= din1_min && din3_max <= din2_min)
						middle <= din3_max;
					else if(din1_min <= din2_min && din1_min <= din3_max)
						middle <= din1_min;
					else if(din2_min <= din1_min && din2_min <= din3_max)
						middle <= din2_min;
				end
				
			else if(din1_mid >= din2_max && din1_mid >= din3_max)
				middle <= din1_min;
			else if(din2_mid >= din1_max && din2_mid >= din3_max)
				middle <= din2_min;
			else if(din3_mid >= din1_max && din3_mid >= din2_max)
				middle <= din3_min;
				
			else
				begin
					if((din2_mid <= din1_mid && din1_mid <= din3_mid) || (din3_mid <= din1_mid && din1_mid <= din2_mid))
						middle <= din1_mid;
					else if((din1_mid <= din2_mid && din2_mid <= din3_mid) || (din3_mid <= din2_mid && din2_mid <= din1_mid))
						middle <= din2_mid;
					else
						middle <= din3_mid;
				end
			dout <= middle;
		end
	else
		begin
			dout <= dout;
			middle <= middle;
		end
end

endmodule
