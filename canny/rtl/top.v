`timescale 1ns / 1ns

module tb_top();

parameter  CLK_PERIOD = 20;		//clk=20ns

reg     sys_clk;
reg		sys_rst_n;
initial 
	begin
		sys_clk <= 1'b0;
		sys_rst_n <= 1'b0;
		#200
		sys_rst_n <= 1'b1;
	end

always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

lcd_rgb_colorbar u_lcd_rgb_colorbar
(
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n)
);

endmodule