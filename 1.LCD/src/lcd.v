
module lcd
(
	input wire CLK_IN,
	input wire RST_IN,
	output wire [7:0] R,
	output wire [7:0] G,
	output wire [7:0] B,
	output wire LCD_CLK,
	output wire LCD_HSYNC,
	output wire LCD_VSYNC,
	output wire LCD_DEN,
	output wire LCD_PWM
);

	parameter LCD_HEIGHT = 272;
	parameter LCD_WIDTH = 479;

	ip_pll pll
	(
		.refclk (CLK_IN),
		.reset (~RST_IN),
		.clk0_out (LCD_CLK)
	);

	wire [10:0] x;
	wire [10:0] y;

	lcd_sync
	#(
		.LCD_HEIGHT(LCD_HEIGHT),
		.LCD_WIDTH(LCD_WIDTH)
	)
	u_lcd_sync
	(
		.CLK (LCD_CLK),
		.RST_IN (RST_IN),
		.LCD_PWM (LCD_PWM),
		.LCD_HSYNC (LCD_HSYNC),
		.LCD_VSYNC (LCD_VSYNC),
		.LCD_DEN (LCD_DEN),
		.X (x),
		.Y (y)
	);

	data_out
	#(
		.LCD_HEIGHT(LCD_HEIGHT),
		.LCD_WIDTH(LCD_WIDTH)
	)
	datout
	(
		.CLK (LCD_CLK),
		.R (R),
		.G (G),
		.B (B),
		.DEN (LCD_DEN),
		.X (x),
		.Y (y)
	);

endmodule
