module fifo_generator_0
(
	clk,
	rst,
	din,
	wr_en,
	rd_en,
	dout,
	empty,
	full,
	wr_rst_busy,
	rd_rst_busy
);

//parameter define 
parameter WIDTH	= 24;			//位宽
parameter DEPTH	= 256;			//深度

//port define
input					clk;
input					rst;
input		[WIDTH-1:0]	din;
input					wr_en;
input					rd_en;
output	reg	[WIDTH-1:0]	dout;
output					empty;
output					full;
output					wr_rst_busy;
output					rd_rst_busy;

//reg define
reg	[7:0]			wr_addr;					//写地址
reg	[7:0]			rd_addr;					//读地址
reg [7:0]			fifo_cnt;					//计数器
reg [WIDTH-1:0] 	fifo [DEPTH-1:0];			//二维数组

assign full  = (fifo_cnt == DEPTH) ? 1'b1 : 1'b0;		//满信号
assign empty = (fifo_cnt == 0) ? 1'b1 : 1'b0;			//空信号
assign wr_rst_busy = rst;
assign rd_rst_busy = 0;									//未使用到该信号，直接给低电平

//写地址逻辑
always @(posedge clk or posedge rst)
begin
	if(rst)
		wr_addr <= 8'd0;
	else
		begin
			if(wr_en)
				begin
					if(wr_addr >= DEPTH - 1)
						wr_addr <= 10'd0;
					else
						wr_addr <= wr_addr + 10'd1;
				end
			else
				wr_addr <= wr_addr;
		end
end

//读地址逻辑
always @(posedge clk or posedge rst)
begin
	if(rst)
		rd_addr <= 8'd0;
	else
		begin
			if(rd_en)
				begin
					if(rd_addr >= DEPTH - 1)
						rd_addr <= 10'd0;
					else
						rd_addr <= rd_addr + 10'd1;
				end
			else
				rd_addr <= rd_addr;
		end
end

//二维数组逻辑
integer  i;
always @(posedge clk or posedge rst)
begin
	if(rst)
		begin
			//wr_rst_busy <= 1'd1;
			for(i=0;i<WIDTH;i=i+1)
				fifo[i] <= 8'd0;
		end
	else
		begin
			//wr_rst_busy <= 1'd0;
			if(wr_en)
				fifo[wr_addr] <= din;
			if(rd_en)
				dout <= fifo[rd_addr];
			else
				dout <= dout;
		end
end

//计数器逻辑
always @(posedge clk or posedge rst)
begin
	if(rst)
		fifo_cnt <= 8'd0;
	else
		begin
			if(wr_en && !rd_en)
				fifo_cnt <= fifo_cnt + 10'd1;
			else if(!wr_en && rd_en)
				begin
					if(fifo_cnt > 0)
						fifo_cnt <= fifo_cnt - 10'd1;
					else
						fifo_cnt <= fifo_cnt;
				end
			else
				fifo_cnt <= fifo_cnt;
		end
end

endmodule