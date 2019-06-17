
module lcd_sync
#(
	parameter LCD_HEIGHT = 280, // Vertical display period
	parameter LCD_WIDTH = 480 // Horizontal display period
)
(
	input wire CLK,
	input wire RST_IN,
	output wire LCD_PWM,
	output wire LCD_HSYNC,
	output wire LCD_VSYNC,
	output wire LCD_DEN,
	output wire [10:0] X,
	output wire [10:0] Y
);
localparam tvf = 4; // Vertical Front porch
localparam tvp = 9; // Vertical Pulse width
localparam tvb = 1; // Vertical Back porch
localparam tv = tvf+tvp+tvb+LCD_HEIGHT; // Vertical cycle

localparam thf = 2; // Horizontal Front porch
localparam thp = 40; // Horizontal Pulse width
localparam thb = 1; // Horizontal Back porch
localparam th = thf+thp+thb+LCD_WIDTH; // Horizontal signal

reg [10:0] counter_hs;
reg [10:0] counter_vs;

always @(posedge CLK)
begin
	if (RST_IN == 1'b0)
	begin
		counter_hs <= 0;
		counter_vs <= 0;
	end
	else
	begin
		if (counter_hs == th)
		begin
			if (counter_vs == tv)
				counter_vs <= 0;
			else
				counter_vs <= counter_vs + 1;
			counter_hs <= 0;
		end
		else
			counter_hs <= counter_hs + 1;
	end
end

assign LCD_PWM = (RST_IN == 1) ? 1'b1 : 1'b0;
assign LCD_VSYNC = (counter_vs < tvp) ? 0 : 1;
assign LCD_HSYNC = (counter_hs < thp) ? 0 : 1;
assign LCD_DEN = (thp+thb<=counter_hs && counter_hs<=th-thf && tvp+tvb<=counter_vs && counter_vs<=tv-tvf) ? 1 : 0;
assign X = LCD_DEN ? counter_hs-thp-thb : 10'b0;
assign Y = LCD_DEN ? counter_vs-tvp-tvb : 10'b0;

endmodule
