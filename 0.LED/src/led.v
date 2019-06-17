module led
	(
		input wire CLK_IN,
		input wire RST_N,
		output wire [2:0] RGB_LED
	);

	parameter time1 = 25'd24_000_000;

	reg [2:0] rledout;
	reg [24:0] count;

	initial
	begin
		count = 25'b0;
		rledout = 3'b1;
	end

	always @(posedge CLK_IN)
	begin
		if (RST_N==0)
		begin
			count <= 25'b0;
			rledout <= 3'b010;
		end

		if (count == time1)
		begin
			count <= 25'd0;

			if (rledout == 3'b100)
			begin
				rledout <= 3'b001;
			end
			else
			begin
				rledout <= {rledout[1:0],1'b0};
			end
		end
		else
			count <= count + 1'b1;
	end

	assign RGB_LED = ~rledout;
endmodule
