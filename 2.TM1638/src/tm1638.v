module tm1638(
	input wire RST_IN,
	input wire [7:0] DATA_IN,
	input wire [3:0] ADDR,
	input wire WRITE,
	input wire CLK_IN,
	output reg STB,
	output wire DIO,
	output wire CLK_OUT,
	output wire READY
);

reg [7:0] dataReg;
reg [3:0] addrReg;
reg [2:0] state;
wire [2:0] stateNext;
reg [10:0] stateBit;
reg [7:0] byteToSend;
reg enableStbUp;
reg enableStbDown;
reg enableClk;
reg clkEnableNext;
reg clkEnable;
reg do;

parameter STATE_PRE_INIT = 3'd0;
parameter STATE_INIT = 3'd1;
parameter STATE_WAIT = 3'd2;
parameter STATE_CMD_WRITE = 3'd3;
parameter STATE_WRITE_ADDR = 3'd4;
parameter STATE_WRITE_DATA = 3'd5;

parameter STATE_BIT_BEGIN = 0;
parameter STATE_BIT_STB_DOWN = 1;
parameter STATE_BIT_WAIT = 2;
parameter STATE_BIT_0 = 3;
parameter STATE_BIT_1 = 4;
parameter STATE_BIT_2 = 5;
parameter STATE_BIT_3 = 6;
parameter STATE_BIT_4 = 7;
parameter STATE_BIT_5 = 8;
parameter STATE_BIT_6 = 9;
parameter STATE_BIT_7_END = 10;

function [2:0] computeNextState(
	input [2:0] state,
	input write
);
case (state)
	STATE_PRE_INIT,
	STATE_INIT,
	STATE_CMD_WRITE,
	STATE_WRITE_ADDR:
		computeNextState = state + 1'b1;
	STATE_WAIT:
		if (write == 1)
			computeNextState = STATE_CMD_WRITE;
		else
			computeNextState = STATE_WAIT;
	STATE_WRITE_DATA:
		computeNextState = STATE_WAIT;
	default:
		computeNextState = STATE_PRE_INIT;
endcase
endfunction

assign stateNext = computeNextState(state, WRITE);

always @(negedge CLK_IN)
begin
	if (RST_IN == 0)
	begin
		state <= STATE_PRE_INIT;
		stateBit <= (11'b1 << STATE_BIT_BEGIN);
		clkEnableNext <= 1'b0;
		STB <= 1'b1;
	end
	else
	begin
		if (stateBit[STATE_BIT_7_END] == 1'b0 && state != STATE_WAIT)
			stateBit <= stateBit<<1;
		else
			stateBit <= (11'b1 << STATE_BIT_BEGIN);

		if (stateBit[STATE_BIT_7_END] == 1'b1 || (state == STATE_WAIT && WRITE == 1'b1))
			state <= stateNext;

		if (stateBit[STATE_BIT_STB_DOWN] == 1'b1)
		begin
			if (enableClk)
				clkEnableNext <= 1'b1;
			if (enableStbDown)
				STB <= 1'b0;
		end
		else if (stateBit[STATE_BIT_6] == 1'b1)
		begin
			if (enableClk)
				clkEnableNext <= 1'b0;
		end
		else if (stateBit[STATE_BIT_7_END] == 1'b1)
		begin
			if (enableStbUp)
				STB <= 1'b1;
		end

		if (state == STATE_WAIT && WRITE == 1)
		begin
			dataReg <= DATA_IN;
			addrReg <= ADDR;
		end
	end
end

always @ (state, dataReg, addrReg)
begin
	case (state)
		STATE_PRE_INIT:
		begin
			// Wait with STB up
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b0;
		end
		STATE_INIT:
		begin
			// Send command: Activate and set max brightness
			byteToSend = 8'b10001111;
			enableStbDown = 1'b1;
			enableStbUp = 1'b1;
			enableClk = 1'b1;
		end
		STATE_WAIT:
		begin
			// Do nothing
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b0;
		end
		STATE_CMD_WRITE:
		begin
			// Send command: data write fixed address
			byteToSend = 8'b01000100;
			enableStbDown = 1'b1;
			enableStbUp = 1'b1;
			enableClk = 1'b1;
		end
		STATE_WRITE_ADDR:
		begin
			// Send address
			byteToSend = {4'b1100,addrReg};
			enableStbDown = 1'b1;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_WRITE_DATA:
		begin
			// Send data
			byteToSend = dataReg;
			enableStbDown = 1'b0;
			enableStbUp = 1'b1;
			enableClk = 1'b1;
		end
		default:
		begin
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b0;
		end
	endcase
end

function [0:0] computeDo(
	input [10:0] stateBit,
	input [7:0] byteToSend
);
begin
	if (stateBit[STATE_BIT_0] == 1'b1)
		computeDo = byteToSend[0];
	else if (stateBit[STATE_BIT_1] == 1'b1)
		computeDo = byteToSend[1];
	else if (stateBit[STATE_BIT_2] == 1'b1)
		computeDo = byteToSend[2];
	else if (stateBit[STATE_BIT_3] == 1'b1)
		computeDo = byteToSend[3];
	else if (stateBit[STATE_BIT_4] == 1'b1)
		computeDo = byteToSend[4];
	else if (stateBit[STATE_BIT_5] == 1'b1)
		computeDo = byteToSend[5];
	else if (stateBit[STATE_BIT_6] == 1'b1)
		computeDo = byteToSend[6];
	else if (stateBit[STATE_BIT_7_END] == 1'b1)
		computeDo = byteToSend[7];
	else
		computeDo = 1'b1;
end
endfunction

always @(posedge CLK_IN)
begin
	if (RST_IN == 0)
		clkEnable <= 1'b0;
	else
		clkEnable <= clkEnableNext;
end

assign CLK_OUT = CLK_IN || !clkEnable;
assign READY = state == STATE_WAIT;
assign DIO = (computeDo(stateBit, byteToSend) ? 1'bz : 1'b0);

endmodule
