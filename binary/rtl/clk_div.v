module clk_div
(
	input					clk,
	input					rst_n,
	
	output			reg		lcd_pclk
);

reg		clk_25m;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		clk_25m <= 1'b0;
	else
		clk_25m <= ~clk_25m;
end

always @(*)
begin
	lcd_pclk = clk_25m;
end

endmodule
