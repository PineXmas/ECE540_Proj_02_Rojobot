// ram_pikachu.v
// Thong & Deepen
//
// Store spites of the infamous PIKACHU!

module ram_pikachu
#(parameter DATA_WIDTH=12, parameter ADDR_WIDTH=15)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	initial
	begin
	  $readmemh("pikachu_02.mem", ram);
	end

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;

		q <= ram[read_addr];
	end

endmodule
