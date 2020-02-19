// robot_icon_v2.v
// Thong & Deepen
//
// Handle Icon of the Rojobot. This version includes sprites and animation

module robot_icon_v2 #(
    parameter SCALING_FACTOR = 6,
    parameter MARGIN = 128,
    parameter ANIMATION_COUNTDOWN = 8_000_000,
    parameter SPRITE_COLS = 34,
    parameter SPRITE_ROWS = 34,
    
    localparam MARGIN_ROW = SPRITE_ROWS / 2 - 9,
    localparam MEM_ROWS = SPRITE_ROWS*8,
    localparam MEM_COLS = SPRITE_COLS*3,
    localparam SPRITE_SIZE = SPRITE_COLS * SPRITE_ROWS,
    localparam FRAME_ROW_SIZE = MEM_COLS * SPRITE_ROWS, 
    localparam ROBOT_CENTER_TO_BOUND_X = (SPRITE_COLS - SCALING_FACTOR) / 2,
    localparam ROBOT_CENTER_TO_BOUND_Y = (SPRITE_ROWS - SCALING_FACTOR) / 2
)(
    input signed [31:0] pixel_row,
    input signed [31:0] pixel_column,
    input signed [31:0] LocX_reg,
    input signed [31:0] LocY_reg,
    input [7:0]         BotInfo_reg,
    input               clk,
    input               reset,
    output reg [11:0]   icon
);

  //*** NOTE: 000 is reserved for transparent color. Use 001 to mimic "black" color
  
  //*** NOTE: too much delay from LocX, LocX to determine robot_x, robot_y. The reason might be due to multiplication
  
  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // robot on screen coordinates mapped back to world coordinates
  reg signed [31:0] robot_x, robot_y;
  
  // robot bounding rectangle in screen coordinates
  reg signed [31:0] robot_screen_left, robot_screen_top, robot_screen_right, robot_screen_bottom;
  
  // counter for next frame in the animation
  reg [31:0] counter;
  
  // frame column & frame row
  reg signed [31:0] frame_col, frame_row;
  
  // control direction to move the frame column: -1 or 1
  reg signed [31:0] frame_direction;
  
  // RAM
  wire [31:0] read_addr;
  wire [11:0] ram_out;
  
  // ==================================================
  // INSTANCES
  // ==================================================
  
  // init the ram
  ram_block #(
    .INIT_FILE("pikachu_02.mem")
  )ram_pikachu(
    .read_addr(read_addr),
    .clk(clk),
    .q(ram_out)
  );
  
  // ==================================================
  // LOGIC
  // ==================================================
  
  // --------------------------------------------------
  // compute ram address
  // --------------------------------------------------
  assign read_addr = frame_row * FRAME_ROW_SIZE + frame_col * SPRITE_COLS + robot_y * MEM_COLS + robot_x; 
  
  
  // --------------------------------------------------
  // counter for next frame column: next frame if timeup, change direction if column 0 or 2
  // --------------------------------------------------
  always @(posedge clk) begin
    if (reset) begin
      counter <= ANIMATION_COUNTDOWN;
      frame_col <= 0;
      frame_direction <= 1;
    end
    else if (BotInfo_reg[7:4] > 0)begin
      // only change frame if robot is still moving
      
      // determine next frame direction based on frame column: 0 then next frame on the right, 2 then next frame on the left 
      if (frame_col == 2) begin
        frame_direction <= -1;
      end
      else if (frame_col == 0) begin
        frame_direction <= 1;
      end
      
      // time up: next frame & reset counter, otherwise keep counting down
      if (counter == 0) begin
        frame_col <= frame_col + frame_direction;
        counter <= ANIMATION_COUNTDOWN;
      end
      else begin
        counter <= counter - 1;
      end
    end
    else begin
      // do not change frame and set frame column to 1
      frame_col <= 1;
    end
  end
  
  // --------------------------------------------------
  // determine pixel color
  // --------------------------------------------------
  always @(*) begin
  
    // robot bounding rect
    robot_screen_left   = LocX_reg     * SCALING_FACTOR     - ROBOT_CENTER_TO_BOUND_X;
    robot_screen_right  = (LocX_reg+1) * SCALING_FACTOR - 1 + ROBOT_CENTER_TO_BOUND_X;
    robot_screen_top    = LocY_reg     * SCALING_FACTOR     - ROBOT_CENTER_TO_BOUND_Y;
    robot_screen_bottom = (LocY_reg+1) * SCALING_FACTOR - 1 + ROBOT_CENTER_TO_BOUND_Y;
  
    // determine robot X pixel mapped to a frame
    robot_x = -1;
    if (  robot_screen_left <= (pixel_column-MARGIN) 
          && (pixel_column-MARGIN) <= robot_screen_right
    ) begin
      robot_x = pixel_column-MARGIN - robot_screen_left;
    end

    // determine robot Y pixel mapped to a frame
    robot_y = -1;
    if (  robot_screen_top <= (pixel_row+MARGIN_ROW) 
          && (pixel_row+MARGIN_ROW) <= robot_screen_bottom
    ) begin
      robot_y = (pixel_row+MARGIN_ROW) - robot_screen_top;
    end
    
    // determine frame row based on orientation: N, NE, E, SE, S, SW, W, NW
    case (BotInfo_reg[2:0])
      3'h0: frame_row = 1;
      3'h1: frame_row = 7;
      3'h2: frame_row = 3;
      3'h3: frame_row = 5;
      3'h4: frame_row = 0;
      3'h5: frame_row = 4;
      3'h6: frame_row = 2;
      3'h7: frame_row = 6;
      default: frame_row = 3;
    endcase
    
    // pixel color
    icon = 12'h000;
    if (     robot_x < 0
          || robot_y < 0
          || frame_row*SPRITE_ROWS + robot_y >= MEM_ROWS
          || frame_row*SPRITE_ROWS + robot_y < 0 
          || frame_col*SPRITE_COLS + robot_x >= MEM_COLS
          || frame_col*SPRITE_COLS + robot_x < 0
    ) begin
      // cyan if out-of-bound
      icon = 12'h000;
    end
    else begin
      icon = ram_out;
    end
    
  end
  
endmodule
