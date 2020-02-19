// title_colorizer.v
// Thong & Deepen
//
// Pick color for the title based on the given pixel coordinates


module title_colorizer
#(
  parameter MARGIN_X = 256 + 128,                                         
  parameter MARGIN_Y = 32,
  parameter TITLE_WIDTH = 256,                                            // 2^8
  parameter TITLE_HEIGHT = 128,                                           // 2^7
  parameter TITLE_ADDR_WIDTH_X = 8,
  parameter TITLE_ADDR_WIDTH_Y = 7,
  localparam TITLE_ADDR_WIDTH = TITLE_ADDR_WIDTH_X + TITLE_ADDR_WIDTH_Y   // computed from the title width and height
)(
  input               clk,            // clock signal
  input signed [31:0] pixel_row,      // pixel row from the dtg
  input signed [31:0] pixel_column,   // pixel column from the dtg
  output [11:0]       title_color     // title color at the given pixel coordinates
);

  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // block RAM
  wire [11:0] ram_out;
  wire [31:0] read_addr;
  
  // adjusted pixel coordinates, based on the margin
  wire signed [31:0] pixel_row_adjusted;
  wire signed [31:0] pixel_column_adjusted;
  
  // out-of-title signal
  wire out_of_title;
  
  // ==================================================
  // INSTANCES
  // ==================================================
  
  // store title as block RAM
  ram_block 
  #(
    .INIT_FILE("title_04.mem"),
    .ADDR_WIDTH(TITLE_ADDR_WIDTH)
  )
    ram_title(
    .clk(clk),
    .read_addr(read_addr),
    .q(ram_out)
  );
  
  // ==================================================
  // LOGIC
  // ==================================================
  
  // determine if the given pixel coordinates out of the title or not
  assign out_of_title = !(pixel_row_adjusted >= 0 && pixel_row_adjusted < TITLE_HEIGHT && pixel_column_adjusted >= 0 && pixel_column_adjusted < TITLE_WIDTH);
  
  // adjust pixel coordinates by subtracting the margins
  assign pixel_row_adjusted     = pixel_row - MARGIN_Y;
  assign pixel_column_adjusted  = pixel_column - MARGIN_X;
  
  // determine read addres for the RAM, by concatenation pixel coordinates
  assign read_addr = {pixel_row_adjusted[TITLE_ADDR_WIDTH_Y-1:0], pixel_column_adjusted[TITLE_ADDR_WIDTH_X-1:0]};
  
  // determine title color if NOT out-of-title, 12'h000 otherwise
  assign title_color = out_of_title ? 12'h000 : ram_out;
  
endmodule
