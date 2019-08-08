module tm1638SegHex4
(
		input wire CLK_IN,
		input wire RST_IN,
		input wire READY,
		output reg READ_BUTTON,
		output reg WRITE_SEG,
		output reg [2:0] SEG_INDEX,
		output wire [3:0] SEG_DATA,
		input wire [31:0] SEG_HEX_ALL
	);

	localparam WRITE_SLOW = 5; // Nice with 20 for humain reading
	localparam READ_SLOW = 0; // TODO

	reg [WRITE_SLOW:0] writeSlowCpt;
	reg [READ_SLOW:0] readSlowCpt;

	always @(posedge CLK_IN)
	begin
		if (RST_IN == 0)
		begin
			writeSlowCpt <= 1;
			readSlowCpt <= 1;
			SEG_INDEX <= 0;
			WRITE_SEG <= 1'b0;
			READ_BUTTON <= 1'b0;
		end
		else
		begin
			// If ready
			if (READY == 1)
			begin
				// If time to read
				if (readSlowCpt == 0)
				begin
					// Ask to read
					READ_BUTTON <= 1'b1;
				end
				// If time to write
				else if (writeSlowCpt == 0)
				begin
					// Ask to write
					WRITE_SEG <= 1'b1;
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
			else if (WRITE_SEG == 1'b1)
			begin
				// Stop asking to write
				WRITE_SEG <= 1'b0;
				// Prepare next data to write
				SEG_INDEX <= SEG_INDEX + 1'b1;
				// Reset write slow compter
				writeSlowCpt <= 1;
			end
			// If read
			else if (READ_BUTTON == 1'b1)
			begin
				// Stop asking to read
				READ_BUTTON <= 1'b0;
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
		3'h7:
			computeHexTo7SegDataIn = data[3:0];
		3'h6:
			computeHexTo7SegDataIn = data[7:4];
		3'h5:
			computeHexTo7SegDataIn = data[11:8];
		3'h4:
			computeHexTo7SegDataIn = data[15:12];
		3'h3:
			computeHexTo7SegDataIn = data[19:16];
		3'h2:
			computeHexTo7SegDataIn = data[23:20];
		3'h1:
			computeHexTo7SegDataIn = data[27:24];
		3'h0:
			computeHexTo7SegDataIn = data[31:28];
	endcase
	endfunction

	assign SEG_DATA = computeHexTo7SegDataIn(SEG_INDEX, SEG_HEX_ALL);

endmodule
