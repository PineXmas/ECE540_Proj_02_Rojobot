// robot_icon.v
// Thong & Deepen
//
// Handle Icon of the Rojobot

module robot_icon #(
    parameter SCALING_FACTOR = 6,
    parameter MARGIN = 128
)(
    input [11:0] pixel_row,
    input [11:0] pixel_column,
    input [31:0] LocX_reg,
    input [31:0] LocY_reg,
    input [7:0] BotInfo_reg,
    output reg [11:0] icon
);

  //*** NOTE: think about how to set transparent pixel  
  
  // ==================================================
  // DECLARATIONS
  // ==================================================
  
  // robot on screen coordinates mapped back to world coordinates
  reg [31:0] robot_x, robot_y;
  
  // robot bounding rectangle in screen coordinates
  reg [31:0] robot_screen_left, robot_screen_top, robot_screen_right, robot_screen_bottom;
  
  // ==================================================
  // LOGIC
  // ==================================================
  
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
      robot_y = pixel_row-MARGIN - robot_screen_top;
    end
    
    // determine color
    if (robot_x != SCALING_FACTOR && robot_y != SCALING_FACTOR) begin
    
      // orientation color
      case (BotInfo_reg[2:0])
        3'h0: icon = robot_y == 0 && (robot_x == 2 || robot_x == 3) ? 12'hF0F : 12'h0F0; 
        3'h1: icon = robot_y == 0 && robot_x == 5                   ? 12'hF0F : 12'h0F0;
        3'h2: icon = robot_x == 5 && (robot_y == 2 || robot_y == 3) ? 12'hF0F : 12'h0F0;
        3'h3: icon = robot_y == 5 && robot_x == 5                   ? 12'hF0F : 12'h0F0;
        3'h4: icon = robot_y == 5 && (robot_x == 2 || robot_x == 3) ? 12'hF0F : 12'h0F0;
        3'h5: icon = robot_y == 5 && robot_x == 0                   ? 12'hF0F : 12'h0F0;
        3'h6: icon = robot_x == 0 && (robot_y == 2 || robot_y == 3) ? 12'hF0F : 12'h0F0;
        3'h7: icon = robot_y == 0 && robot_x == 0                   ? 12'hF0F : 12'h0F0;
        default: icon = 12'h0F0;
      endcase
    end
    else begin
      icon = 12'h000;
    end
    
  end
  
endmodule
