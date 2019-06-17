
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

localparam dotSize = 5;

reg [23:0] color;
reg [31:0] cptTime;
reg [8:0] dotX;
reg [8:0] dotY;
reg dirX;
reg dirY;

always@(posedge CLK)
begin
	if (cptTime == 32'd150_000)
	begin
		cptTime <= 32'b0;
		if (dirX)
		begin
			if (dotX == LCD_WIDTH-dotSize-1)
				dirX <= ~dirX;
			else
				dotX <= dotX + 1'b1;
		end
		else
		begin
			if (dotX == dotSize+1)
				dirX <= ~dirX;
			else
				dotX <= dotX - 1'b1;
		end
		if (dirY)
		begin
			if (dotY == LCD_HEIGHT-dotSize-1)
				dirY <= ~dirY;
			else
				dotY <= dotY + 1'b1;
		end
		else
		begin
			if (dotY == dotSize+1)
				dirY <= ~dirY;
			else
				dotY <= dotY - 1'b1;
		end
	end
	else
		cptTime <= cptTime + 1'b1;

	if (DEN)
	begin
		if (X==0 || X == LCD_WIDTH-1 || Y==0 || Y==LCD_HEIGHT-1)
			color[23:0] <= 24'hffffff;
		else if (dotX-dotSize <= X && X <= dotX+dotSize && dotY-dotSize <= Y && Y <= dotY+dotSize)
			color[23:0] <= 24'hffffff;
		else if (X < (LCD_WIDTH/3))
			color[23:0] <= 24'hff0000;
		else if (X < (LCD_WIDTH/3*2))
			color[23:0] <= 24'h00ff00;
		else
			color[23:0] <= 24'h0000ff;
	end
	else
		color <= 24'h000000;
end

assign R = color[23:16];
assign G = color[15:8];
assign B = color[7:0];

endmodule
