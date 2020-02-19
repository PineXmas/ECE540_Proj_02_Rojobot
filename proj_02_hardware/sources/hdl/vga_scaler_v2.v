// vga_scaler_v2.v
// Thong & Deepen
//
// Determine the corresponding map address for a given screen position.
// This version ultilizes combinational logic

module vga_scaler_v2
#(
  parameter SCREEN_TO_WORLD_RATIO_COL = 6,
  parameter SCREEN_TO_WORLD_RATIO_ROW = 6,
  parameter WORLD_COLS = 128,
  parameter WORLD_ROWS = 128,
  localparam MARGIN = 128  
)(
  input      [11:0] pixel_row, pixel_column,    // input pixel coordinates
  output reg [ 6:0] world_row, world_column,    // corresponding row & column with thr pixel coordinates
  output     [13:0] vid_addr,                   // concatenation of {world row, world column}
  output            out_of_map                  // indicate if the given pixel coordinates out-of-map (1) or not (0)
);

  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // index for the for loop
  reg [11:0] i;
  
  // flag for out-of-map signal
  reg out_of_map_X, out_of_map_Y;
  
  // ==================================================
  // LOGIC
  // ==================================================
  
  // assign video address signal
  assign vid_addr = {world_row, world_column};
  
  // assign out-of-map signal
  assign out_of_map = out_of_map_X | out_of_map_Y; 
  
  always @(*) begin
    // traverse columns (in screen-domain) to determine world column
    world_column = 0;
    out_of_map_X = 1;
    for (i=0; i<WORLD_COLS; i=i+1) begin
      if (  i*SCREEN_TO_WORLD_RATIO_COL <= (pixel_column-MARGIN) 
            && (pixel_column-MARGIN) < (i+1) * SCREEN_TO_WORLD_RATIO_COL) begin
        world_column = i;
        out_of_map_X = 0;
      end
    end

    // traverse rows (in screen-domain) to determine world row
    world_row = 0;
    out_of_map_Y = 1;
    for (i=0; i<WORLD_ROWS; i=i+1) begin
      if (  i*SCREEN_TO_WORLD_RATIO_ROW <= pixel_row
            && pixel_row < (i+1) * SCREEN_TO_WORLD_RATIO_ROW) begin
        world_row = i;
        out_of_map_Y = 0;
      end
    end
  end

endmodule
