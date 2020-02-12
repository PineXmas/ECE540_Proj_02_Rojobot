// vga_scaler.v
// Thong & Deepen
//
// Determine the corresponding map address for a given screen position 

module vga_scaler
#(
  parameter SCREEN_TO_WORLD_RATIO_COL = 6,
  parameter SCREEN_TO_WORLD_RATIO_ROW = 6,
  parameter MAX_SCREEN_COLS = 1024,
  parameter MAX_SCREEN_ROWS = 768
)(
  input             clk, reset,                 // clock & reset signals
  input      [11:0] pixel_row, pixel_column,    // input pixel coordinates
  input             video_on,                   // video_on signal from the dtg
  output reg [ 6:0] world_row, world_column,    // corresponding row & column with thr pixel coordinates
  output     [13:0] vid_addr                    // concatenation of {world row, world column}
);

  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // count to SCREEN_TO_WORLD_RATIO_COL & SCREEN_TO_WORLD_RATIO_ROW
  reg [31:0] count_col, count_row;
  
  // count to MAX_SCREEN_COLS & MAX_SCREEN_ROWS
  reg [31:0] accum_cols, accum_rows;
  
  // enable signal: ON when video_on AND pixel_col, pixel_column is in range 
  wire enable;
  
  // ==================================================
  // LOGIC
  // ==================================================
  
  // assign video address
  assign vid_addr = {world_row, world_column};
  
  // determine enable signal
  assign enable = video_on && (pixel_column >= 0) && (pixel_column < MAX_SCREEN_COLS) && (pixel_row >= 0) && (pixel_row < MAX_SCREEN_ROWS);
  
  // counting & adjust corresponding world position
  always @(posedge clk) begin
    if (reset) begin
      world_row <= 0;
      world_column <= 0;
      
      count_col <= 0;
      count_row <= 0;
      
      accum_cols <= 0;
      accum_rows <= 0;
    end
    else if (enable) begin
      
      // increase column info
      count_col  <= count_col  + 1;
      accum_cols <= accum_cols + 1;
      
      // check to increase world column
      if (count_col + 1 >= SCREEN_TO_WORLD_RATIO_COL) begin
        count_col <= 0;
        world_column <= world_column + 1;
      end
      
      // check to increase world row
      if (accum_cols + 1 >= MAX_SCREEN_COLS) begin
      
        // reset all column info to 0
        count_col <= 0;
        accum_cols <= 0;
        world_column <= 0;
        
        // increase row info
        count_row <= count_row + 1;
        accum_rows <= accum_rows + 1;
        
        // reset row info as well if the entire screen has been traversed
        if (accum_rows + 1 >= MAX_SCREEN_ROWS) begin
          count_row <= 0;
          accum_rows <= 0;
          world_row <= 0;  
        end
        
        // double check reset: when both pixel coordinates are 0
        if (pixel_row == 0 && pixel_column == 0) begin
          world_row <= 0;
          world_column <= 0;
          
          count_col <= 0;
          count_row <= 0;
          
          accum_cols <= 0;
          accum_rows <= 0;
        end
      end
    end
  end

endmodule
