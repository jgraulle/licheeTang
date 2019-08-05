module tm1638BtmDisp(
		input wire CLK_IN,
		input wire RST_IN,
		output wire TM1638_STB,
		output wire TM1638_CLK,
		inout wire TM1638_DIO
	);

	parameter CLOCK_SLOW = 6; // Work in reel: drive1=[2-15] openDrain=[6-15]
	parameter WRITE_SLOW = 0; // Nice with 20 for humain reading
	parameter READ_SLOW = 0; // TODO

	reg [CLOCK_SLOW:0] clkSlowCpt;
	reg [WRITE_SLOW:0] writeSlowCpt;
	reg [READ_SLOW:0] readSlowCpt;
	reg [23:0] data;
	reg [2:0] hexaIndex;

	wire tm1638Ready;
	wire [3:0] hexTo7SegDataIn;
	wire [7:0] tm1638DataIn;
	wire [7:0] tm1638DataOut;
	wire tm1638ClkIn;
	reg [3:0] tm1638Addr;
	reg tm1638W;
	reg tm1638R;

	assign tm1638ClkIn = clkSlowCpt[CLOCK_SLOW];

	always @(posedge CLK_IN)
	begin
		if (RST_IN == 0)
		begin
			clkSlowCpt <= 0;
			writeSlowCpt <= 1;
			readSlowCpt <= 1;
			data <= 0;
			hexaIndex <= 0;
			tm1638W <= 1'b0;
			tm1638R <= 1'b0;
		end
		else
		begin
			clkSlowCpt <= clkSlowCpt + 1'b1;

			// If ready
			if (tm1638Ready == 1)
			begin
				// If time to read
				if (readSlowCpt == 0)
				begin
					// Ask to read
					tm1638R <= 1'b1;
				end
				// If time to write
				else if (writeSlowCpt == 0)
				begin
					// Ask to write
					tm1638W <= 1'b1;
					// Prepare to write
					tm1638Addr <= {hexaIndex, 1'b0};
				end
				else
				begin
					// Wait time to write
					writeSlowCpt <= writeSlowCpt + 1'b1;
					// Wait time to read
					readSlowCpt <= readSlowCpt + 1'b1;
				end
			end
			// If write
			else if (tm1638W == 1'b1)
			begin
				// Stop asking to write
				tm1638W <= 1'b0;
				// Prepare next data to write
				hexaIndex <= hexaIndex + 1'b1;
				if (hexaIndex == 3'b111)
					data <= data + 1'b1;
				// Reset write slow compter
				writeSlowCpt <= 1;
			end
			// If read
			else if (tm1638R == 1'b1)
			begin
				// Stop asking to read
				tm1638R <= 1'b0;
				// Reset read slow compter
				readSlowCpt <= 1;
			end
		end
	end

	function [3:0] computeHexTo7SegDataIn(
		input [2:0] index,
		input [31:0] data
	);
	case (index)
		3'h0:
			computeHexTo7SegDataIn = data[3:0];
		3'h1:
			computeHexTo7SegDataIn = data[7:4];
		3'h2:
			computeHexTo7SegDataIn = data[11:8];
		3'h3:
			computeHexTo7SegDataIn = data[15:12];
		3'h4:
			computeHexTo7SegDataIn = data[19:16];
		3'h5:
			computeHexTo7SegDataIn = data[23:20];
		3'h6:
			computeHexTo7SegDataIn = data[27:24];
		3'h7:
			computeHexTo7SegDataIn = data[31:28];
	endcase
	endfunction

	assign hexTo7SegDataIn = computeHexTo7SegDataIn(hexaIndex, {tm1638DataOut,data});

	hexTo7Seg hexTo7Seg_1
	(
		.HEX (hexTo7SegDataIn),
		.DOT (1'b0),
		.SEG (tm1638DataIn)
	);

	tm1638 tm1638_1
	(
		.RST_IN (RST_IN),
		.DATA_IN (tm1638DataIn),
		.DATA_OUT (tm1638DataOut),
		.ADDR (tm1638Addr),
		.WRITE (tm1638W),
		.READ (tm1638R),
		.CLK_IN (tm1638ClkIn),
		.STB (TM1638_STB),
		.DIO (TM1638_DIO),
		.CLK_OUT (TM1638_CLK),
		.READY (tm1638Ready)
	);

endmodule
