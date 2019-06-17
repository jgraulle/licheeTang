
module data_out
#(
	parameter LCD_HEIGHT = 280,
	parameter LCD_WIDTH = 480
)
(
	input wire CLK,
	output wire [7:0] R,
	output wire [7:0] G,
	output wire [7:0] B,
	input  wire DEN,
	input  wire [10:0] X,
	input  wire [10:0] Y
);

reg [23:0] color;
reg [31:0] cptTime;
reg direction;

always@(posedge CLK)
begin
	if (cptTime == 32'd15_000_000)
	begin
		cptTime <= 32'b0;
		direction <= ~direction;
	end
	else
		cptTime <= cptTime + 1'b1;

	if (DEN)
	begin
		if (direction)
		begin
			if (X < (LCD_WIDTH/3))
				color[23:0] <= 24'hff0000;
			else if (X < (LCD_WIDTH/3*2))
				color[23:0] <= 24'h00ff00;
			else
				color[23:0] <= 24'h0000ff;
		end
		else
		begin
			if (Y < (LCD_HEIGHT/3))
				color[23:0] <= 24'hff0000;
			else if (Y < (LCD_HEIGHT/3*2))
				color[23:0] <= 24'h00ff00;
			else
				color[23:0] <= 24'h0000ff;
		end
	end
	else
		color <= 24'h000000;
end

assign R = color[23:16];
assign G = color[15:8];
assign B = color[7:0];

endmodule
