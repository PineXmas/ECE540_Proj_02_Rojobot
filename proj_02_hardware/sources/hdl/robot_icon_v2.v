// robot_icon.v
// Thong & Deepen
//
// Handle Icon of the Rojobot. This version includes sprites and animation

module robot_icon_v2 #(
    parameter SCALING_FACTOR = 34,
    parameter MARGIN = 128,
    parameter ANIMATION_COUNTDOWN = 35000000,
    localparam MEM_ROWS = SCALING_FACTOR*8,
    localparam MEM_COLS = SCALING_FACTOR*3
)(
    input signed [31:0] pixel_row,
    input signed [31:0] pixel_column,
    input signed [31:0] LocX_reg,
    input signed [31:0] LocY_reg,
    input [7:0]         BotInfo_reg,
    input               clk,
    input               reset,
    output reg [11:0] icon
);

  //*** NOTE: 000 is reserved for transparent color. Use 001 to mimic "black" color
  
  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // robot on screen coordinates mapped back to world coordinates
  reg signed [31:0] robot_x, robot_y;
  
  // robot bounding rectangle in screen coordinates
  reg signed [31:0] robot_screen_left, robot_screen_top, robot_screen_right, robot_screen_bottom;
  
  // counter for next frame in the animation
  reg [31:0] counter;
  
  // ROM storing the animation sprites
  reg [11:0] mem [MEM_ROWS-1:0][MEM_COLS-1:0];
  
  // current frame column & frame row
  reg signed [31:0] frame_col, frame_row;
  
  // control direction to move the frame column: -1 or 1
  reg signed [31:0] frame_direction;
  
  // ==================================================
  // LOGIC
  // ==================================================
  
  // init memory
  initial begin
    $readmemh("pikachu.mem", mem);
  end
  
  // counter
  always @(posedge clk) begin
    if (reset) begin
      counter <= ANIMATION_COUNTDOWN;
      frame_col <= 0;
      frame_direction <= 1;
    end
    else begin
      // determine frame column direction
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
  end
  
  // determine pixel color
  always @(posedge clk) begin
  
    if (  robot_x >= SCALING_FACTOR
          || robot_y >= SCALING_FACTOR
          || robot_x < 0
          || robot_y < 0
    ) begin
      // transparent if not robot pixel
      icon <= 12'h000;
    end
    else if (  frame_row*SCALING_FACTOR + robot_y >= MEM_ROWS
          || frame_row*SCALING_FACTOR + robot_y < 0 
          || frame_col*SCALING_FACTOR + robot_x >= MEM_COLS
          || frame_col*SCALING_FACTOR + robot_x < 0
    ) begin
      // cyan if out-of-bound
      icon <= 12'h0FF;
    end
    else begin
      icon <= mem[frame_row*SCALING_FACTOR + robot_y][frame_col*SCALING_FACTOR + robot_x];
    end
  end
  
  // determine robot X and Y pixels corresponding to the screen coordinates
  always @(*) begin
  
    // robot bounding rect
    robot_screen_left   = LocX_reg * SCALING_FACTOR;
    robot_screen_right  = (LocX_reg+1) * SCALING_FACTOR - 1;
    robot_screen_top    = LocY_reg * SCALING_FACTOR;
    robot_screen_bottom = (LocY_reg+1) * SCALING_FACTOR - 1;
  
    // determine robot X pixel
    robot_x = SCALING_FACTOR;
    if (  robot_screen_left <= (pixel_column-MARGIN) 
          && (pixel_column-MARGIN) <= robot_screen_right
    ) begin
      robot_x = pixel_column-MARGIN - robot_screen_left;
    end

    // determine robot Y pixel
    robot_y = SCALING_FACTOR;
    if (  robot_screen_top <= pixel_row 
          && pixel_row <= robot_screen_bottom
    ) begin
      robot_y = pixel_row - robot_screen_top;
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
    
  end
  
endmodule
