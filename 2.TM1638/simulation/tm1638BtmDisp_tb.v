`timescale 1ns / 100ps

module tm1638BtmDisp_tb();

reg CLK_IN;
reg RST_IN;
wire TM1638_STB;
wire TM1638_CLK;
tri1 TM1638_DIO;

reg [7:0] byte;
reg dio;
reg [2:0] hexaIndex;

glbl glbl();

defparam uut.CLOCK_SLOW = 0;
defparam uut.WRITE_SLOW = 0;
defparam uut.READ_SLOW = 0;

tm1638BtmDisp uut(
	.CLK_IN(CLK_IN),
	.RST_IN(RST_IN),
	.TM1638_STB(TM1638_STB),
	.TM1638_CLK(TM1638_CLK),
	.TM1638_DIO(TM1638_DIO)
);

assign TM1638_DIO = dio;

initial begin
	CLK_IN = 1;
	forever #41 CLK_IN = ~CLK_IN; // generate a clock arround 24Mhz
end

task assert(input integer value, input integer expected, input [1024*8-1:0] name, input integer line);
begin
	if (expected !== value)
	begin
		$display("ERROR: with '%0s' on %0d expected %0b get %0b", name, line, expected, value);
		#1000
		$stop;
	end
end
endtask

task readByte(output [7:0] byte);
reg [3:0] bitCpt;
begin
	bitCpt = 0;
	repeat (8)
	begin
		@(negedge TM1638_CLK);
		assert(TM1638_STB, 0, "TM1638_STB", `__LINE__);
		@(posedge TM1638_CLK);
		assert(TM1638_STB, 0, "TM1638_STB", `__LINE__);
		byte[bitCpt] = TM1638_DIO;
		bitCpt = bitCpt + 1;
	end
end
endtask

task writeByte(input [7:0] byte);
reg [3:0] bitCpt;
begin
	bitCpt = 0;
	repeat (8)
	begin
		@(negedge TM1638_CLK);
		assert(TM1638_STB, 0, "TM1638_STB", `__LINE__);
		dio = byte[bitCpt];
		bitCpt = bitCpt + 1;
		@(posedge TM1638_CLK);
		assert(TM1638_STB, 0, "TM1638_STB", `__LINE__);
	end
	#41
	dio = 1'bz;
end
endtask

initial begin
	dio = 1'bz;
	hexaIndex = 0;
	// Reset
	RST_IN = 1;
	#500
	RST_IN = 0;
	#500
	RST_IN = 1;

	// Send to TM1638: Init
	@(negedge TM1638_STB);
	readByte(byte);
	@(posedge TM1638_STB);
	assert(byte, 8'b10001111, "byte", `__LINE__);

	repeat (8)
	begin
		// Send to TM1638: command read
		@(negedge TM1638_STB);
		readByte(byte);
		assert(byte, 8'b01000010, "byte", `__LINE__);
		assert(TM1638_CLK, 1'b1, "TM1638_CLK", `__LINE__);

		// Read from TM1638: button state (only bit 0 and 4 of each byte)
		writeByte(8'b00000001);
		writeByte(8'b00000000);
		writeByte(8'b00000000);
		writeByte(8'b00010000);
		@(posedge TM1638_STB);

		// Send to TM1638: command write
		@(negedge TM1638_STB);
		readByte(byte);
		@(posedge TM1638_STB);
		assert(byte, 8'b01000100, "byte", `__LINE__);

		// Send to TM1638: addr hexaIndex
		@(negedge TM1638_STB);
		readByte(byte);
		assert(byte, {4'b1100, hexaIndex, 1'b0}, "byte", `__LINE__);

		// Send to TM1638: data display X
		readByte(byte);
		@(posedge TM1638_STB);
		if (hexaIndex == 6)
			// Display 1
			assert(byte, 8'b00000110, "byte", `__LINE__);
		else if (hexaIndex == 7)
			// Display 8
			assert(byte, 8'b01111111, "byte", `__LINE__);
		else
			// Display 0
			assert(byte, 8'b00111111, "byte", `__LINE__);

		hexaIndex = hexaIndex + 1;
	end

	#500
	$display("SUCCESS");
	$stop;
end

endmodule
