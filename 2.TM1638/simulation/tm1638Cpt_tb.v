`timescale 1ns / 100ps

module tm1638Cpt_tb();

reg CLK_IN;
reg RST_IN;
wire TM1638_STB;
wire TM1638_CLK;
tri1 TM1638_DIO;

reg [7:0] byte;

glbl glbl();

defparam uut.CLOCK_SLOW = 0;
defparam uut.WRITE_SLOW = 0;

tm1638Cpt uut(
	.CLK_IN(CLK_IN),
	.RST_IN(RST_IN),
	.TM1638_STB(TM1638_STB),
	.TM1638_CLK(TM1638_CLK),
	.TM1638_DIO(TM1638_DIO)
);

initial begin
	CLK_IN = 0;
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

initial begin
	// Reset
	RST_IN = 1;
	#500
	RST_IN = 0;
	#500
	RST_IN = 1;

	// Send to TM1638: Init
	@(negedge TM1638_STB);
	readByte(byte);
	assert(byte, 8'b10001111, "byte", `__LINE__);
	@(posedge TM1638_STB);

	// Send to TM1638: Write data
	@(negedge TM1638_STB);
	readByte(byte);
	assert(byte, 8'b01000100, "byte", `__LINE__);
	@(posedge TM1638_STB);

	// Send to TM1638: addr 0
	@(negedge TM1638_STB);
	readByte(byte);
	assert(byte, 8'b11000000, "byte", `__LINE__);

	// Send to TM1638: data display 0
	readByte(byte);
	assert(byte, 8'b00111111, "byte", `__LINE__);
	@(posedge TM1638_STB);


	// Send to TM1638: Write data
	@(negedge TM1638_STB);
	readByte(byte);
	assert(byte, 8'b01000100, "byte", `__LINE__);
	@(posedge TM1638_STB);

	// Send to TM1638: addr 2
	@(negedge TM1638_STB);
	readByte(byte);
	assert(byte, 8'b11000010, "byte", `__LINE__);

	// Send to TM1638: data display 1
	readByte(byte);
	assert(byte, 8'b00000110, "byte", `__LINE__);
	@(posedge TM1638_STB);

	#10
	$display("SUCCESS");
	$stop;
end

endmodule
