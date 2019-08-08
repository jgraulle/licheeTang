module tm1638(
	input wire RST_IN,
	output wire READY,
	input wire READ,
	input wire WRITE,
	output reg [7:0] DATA_OUT,
	input wire [3:0] ADDR_IN,
	input wire [7:0] DATA_IN,
	input wire CLK_IN,
	output reg STB,
	output wire CLK_OUT,
	inout wire DIO
);

reg [7:0] dataInReg;
reg [3:0] addrInReg;
reg [3:0] state;
wire [3:0] stateNext;
reg [10:0] stateBit;
reg [7:0] byteToSend;
reg enableStbUp;
reg enableStbDown;
reg enableClk;
reg clkEnableNext;
reg clkEnable;
reg do;

parameter BRIHGTNESS = 3'b000;

parameter STATE_PRE_INIT = 4'd0;
parameter STATE_INIT = 4'd1;
parameter STATE_WAIT = 4'd2;
parameter STATE_CMD_WRITE = 4'd3;
parameter STATE_WRITE_ADDR_IN = 4'd4;
parameter STATE_WRITE_DATA = 4'd5;
parameter STATE_CMD_READ = 4'd6;
parameter STATE_READ_DATA_1 = 4'd7;
parameter STATE_READ_DATA_2 = 4'd8;
parameter STATE_READ_DATA_3 = 4'd9;
parameter STATE_READ_DATA_4 = 4'd10;

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

function [3:0] computeNextState(
	input [3:0] state,
	input write,
	input read
);
case (state)
	STATE_PRE_INIT,
	STATE_INIT,
	STATE_CMD_WRITE,
	STATE_WRITE_ADDR_IN,
	STATE_CMD_READ,
	STATE_READ_DATA_1,
	STATE_READ_DATA_2,
	STATE_READ_DATA_3:
		computeNextState = state + 1'b1;
	STATE_WAIT:
		if (read == 1)
			computeNextState = STATE_CMD_READ;
		else if (write == 1)
			computeNextState = STATE_CMD_WRITE;
		else
			computeNextState = STATE_WAIT;
	STATE_WRITE_DATA,
	STATE_READ_DATA_4:
		computeNextState = STATE_WAIT;
	default:
		computeNextState = STATE_WAIT;
endcase
endfunction

assign stateNext = computeNextState(state, WRITE, READ);

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

		if (stateBit[STATE_BIT_7_END] == 1'b1 || (state == STATE_WAIT && (WRITE == 1'b1 || READ == 1'b1)))
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
			dataInReg <= DATA_IN;
			addrInReg <= ADDR_IN;
		end
	end
end

always @ (state, dataInReg, addrInReg)
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
			// Send command: Activate and set min brightness
			byteToSend = {5'b10001,BRIHGTNESS};
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
		STATE_WRITE_ADDR_IN:
		begin
			// Send address
			byteToSend = {4'b1100,addrInReg};
			enableStbDown = 1'b1;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_WRITE_DATA:
		begin
			// Send data
			byteToSend = dataInReg;
			enableStbDown = 1'b0;
			enableStbUp = 1'b1;
			enableClk = 1'b1;
		end
		STATE_CMD_READ:
		begin
			// Send command: data read fixed address
			byteToSend = 8'b01000010;
			enableStbDown = 1'b1;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_READ_DATA_1:
		begin
			// Read data
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_READ_DATA_2:
		begin
			// Read data
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_READ_DATA_3:
		begin
			// Read data
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b0;
			enableClk = 1'b1;
		end
		STATE_READ_DATA_4:
		begin
			// Read data
			byteToSend = 8'b11111111;
			enableStbDown = 1'b0;
			enableStbUp = 1'b1;
			enableClk = 1'b1;
		end
		default:
		begin
			// Do nothing
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

always @(posedge CLK_IN)
begin
	if (state == STATE_READ_DATA_1 && stateBit[STATE_BIT_0] == 1'b1)
		DATA_OUT[0] <= DIO;
	else if (state == STATE_READ_DATA_2 && stateBit[STATE_BIT_0] == 1'b1)
		DATA_OUT[1] <= DIO;
	else if (state == STATE_READ_DATA_3 && stateBit[STATE_BIT_0] == 1'b1)
		DATA_OUT[2] <= DIO;
	else if (state == STATE_READ_DATA_4 && stateBit[STATE_BIT_0] == 1'b1)
		DATA_OUT[3] <= DIO;
	else if (state == STATE_READ_DATA_1 && stateBit[STATE_BIT_4] == 1'b1)
		DATA_OUT[4] <= DIO;
	else if (state == STATE_READ_DATA_2 && stateBit[STATE_BIT_4] == 1'b1)
		DATA_OUT[5] <= DIO;
	else if (state == STATE_READ_DATA_3 && stateBit[STATE_BIT_4] == 1'b1)
		DATA_OUT[6] <= DIO;
	else if (state == STATE_READ_DATA_4 && stateBit[STATE_BIT_4] == 1'b1)
		DATA_OUT[7] <= DIO;
end

assign CLK_OUT = (CLK_IN || !clkEnable);
assign READY = (state == STATE_WAIT);
assign DIO = (computeDo(stateBit, byteToSend) ? 1'bz : 1'b0);

endmodule
