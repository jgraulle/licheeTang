module lcdPong
#(
	parameter LCD_HEIGHT = 280,
	parameter LCD_WIDTH = 480
)
(
	input wire CLK,
	input wire RST_IN,
	output wire [7:0] R,
	output wire [7:0] G,
	output wire [7:0] B,
	input wire DEN,
	input wire [10:0] X,
	input wire [10:0] Y,
	output wire [31:0] SEG_HEX_ALL,
	input wire [7:0] BUTTONS
);

localparam BALL_SLOW = 32'd150_000;
localparam BALL_SIZE = 5;
localparam RACKET_SIZE = 40;
localparam RACKET_Y_SLOW = 15; // For humain control [14-18]

reg [23:0] color;
reg [31:0] cptTime;
reg [8:0] ballX;
reg [8:0] ballY;
reg ballDirX;
reg ballDirY;
reg [8:0] racket1Y;
reg [8:0] racket2Y;
reg [RACKET_Y_SLOW:0] racket1YSlowCpt;
reg [RACKET_Y_SLOW:0] racket2YSlowCpt;
reg [7:0] score1;
reg [7:0] score2;

always@(posedge CLK)
begin
	if (RST_IN == 0)
	begin
		racket1Y <= 0;
		racket1YSlowCpt <= 0;
		racket2Y <= 0;
		racket2YSlowCpt <= 0;
		score1 <= 0;
		score2 <= 0;
	end
	else
	begin
		// Update ball position
		if (cptTime == BALL_SLOW)
		begin
			cptTime <= 0;
			if (ballDirX)
			begin
				if (ballX == LCD_WIDTH-1-BALL_SIZE && racket2Y <= ballY && ballY <= racket2Y+RACKET_SIZE)
					ballDirX <= ~ballDirX;
				else if (ballX == LCD_WIDTH-1)
				begin
					ballX <= BALL_SIZE+1;
					score1 <= score1+1;
				end
				else
					ballX <= ballX + 1'b1;
			end
			else
			begin
				if (ballX == BALL_SIZE && racket1Y <= ballY && ballY <= racket1Y+RACKET_SIZE)
					ballDirX <= ~ballDirX;
				else if (ballX == 0)
				begin
					ballX <= LCD_WIDTH-2-BALL_SIZE;
					score2 <= score2+1;
				end
				else
					ballX <= ballX - 1'b1;
			end
			if (ballDirY)
			begin
				if (ballY == LCD_HEIGHT-1-BALL_SIZE)
					ballDirY <= ~ballDirY;
				else
					ballY <= ballY + 1'b1;
			end
			else
			begin
				if (ballY == BALL_SIZE)
					ballDirY <= ~ballDirY;
				else
					ballY <= ballY - 1'b1;
			end
		end
		else
			cptTime <= cptTime + 1'b1;

		// Update racket player 1 position
		{racket1Y, racket1YSlowCpt} <= {racket1Y, racket1YSlowCpt} + BUTTONS[0] - BUTTONS[1];
		if (racket1Y == 0)
			racket1Y <= 1;
		else if (LCD_HEIGHT-RACKET_SIZE == racket1Y)
			racket1Y <= LCD_HEIGHT-RACKET_SIZE-1;

		// Update racket player 2 position
		{racket2Y, racket2YSlowCpt} <= {racket2Y, racket2YSlowCpt} + BUTTONS[6] - BUTTONS[7];
		if (racket2Y == 0)
			racket2Y <= 1;
		else if (LCD_HEIGHT-RACKET_SIZE == racket2Y)
			racket2Y <= LCD_HEIGHT-RACKET_SIZE-1;

		// Update screen
		if (DEN)
		begin
			// Display racket player 1
			if (X==0 && racket1Y<Y && Y<racket1Y+RACKET_SIZE)
				color[23:0] <= 24'h00ff00;
			// Display racket player 2
			else if (X == LCD_WIDTH-1 && racket2Y<Y && Y<racket2Y+RACKET_SIZE)
				color[23:0] <= 24'h00ff00;
			// Display ball
			else if (ballX-BALL_SIZE <= X && X <= ballX+BALL_SIZE && ballY-BALL_SIZE <= Y && Y <= ballY+BALL_SIZE)
				color[23:0] <= 24'hff0000;
			// Display border
			else if (Y==0 || Y==LCD_HEIGHT-1)
				color[23:0] <= 24'hffffff;		
			else
				color[23:0] <= 24'h000000;
		end
		else
			color <= 24'h000000;
	end
end

assign R = color[23:16];
assign G = color[15:8];
assign B = color[7:0];

assign SEG_HEX_ALL = {score1, 8'b0, 8'b0, score2};

endmodule
