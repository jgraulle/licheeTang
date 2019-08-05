module tm1638Cpt(
		input wire CLK_IN,
		input wire RST_IN,
		output wire TM1638_STB,
		output wire TM1638_CLK,
		output wire TM1638_DIO
	);

	parameter CLOCK_SLOW = 5; // Work in reel between 2 and 15
	parameter WRITE_SLOW = 20; // Nice with 20 for humain reading

	wire tm1638Ready;
	wire [7:0] tm1638DataIn;

	reg [CLOCK_SLOW:0] clkSlowCpt;
	reg [WRITE_SLOW:0] writeSlowCpt;
	reg [3:0] data;
	reg [3:0] tm1638Addr;
	reg tm1638W;

	always @(posedge CLK_IN)
	begin
		if (RST_IN == 0)
		begin
			clkSlowCpt <= 0;
			writeSlowCpt <= 1;
			data <= 4'b1111;
			tm1638Addr <= 4'b1110;
			tm1638W <= 1'b0;
		end
		else
		begin
			clkSlowCpt <= clkSlowCpt + 1'b1;

			// If ready
			if (tm1638Ready == 1)
			begin
				// Wait time to write
				if (writeSlowCpt != 0)
					writeSlowCpt <= writeSlowCpt + 1'b1;
				// If time to write
				else
				begin
					// Ask to write
					tm1638W <= 1'b1;
					// Prepare to write
					tm1638Addr <= {tm1638Addr[3:1] + 1'b1, 1'b0};
					data <= data + 1'b1;
				end
			end
			// If write
			else if (tm1638W == 1'b1)
			begin
				// Stop asking to write
				tm1638W <= 1'b0;
				// Reset write slow compter
				writeSlowCpt <= 1;
			end
		end
	end

	hexTo7Seg hexTo7Seg_1
	(
		.HEX (data),
		.DOT (1'b0),
		.SEG (tm1638DataIn)
	);

	tm1638 tm1638_1
	(
		.RST_IN (RST_IN),
		.DATA_IN (tm1638DataIn),
		.ADDR (tm1638Addr),
		.WRITE (tm1638W),
		.CLK_IN (clkSlowCpt[CLOCK_SLOW]),
		.STB (TM1638_STB),
		.DIO (TM1638_DIO),
		.CLK_OUT (TM1638_CLK),
		.READY (tm1638Ready)
	);

endmodule
