// ram_pikachu.v
// Thong & Deepen
//
// Init block RAM from a given mem file

module ram_block
#(
  parameter DATA_WIDTH=12, 
  parameter ADDR_WIDTH=15,
  parameter INIT_FILE="pikachu_02.mem"
)(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	initial
	begin
	  $readmemh(INIT_FILE, ram);
	end

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;

		q <= ram[read_addr];
	end

endmodule
