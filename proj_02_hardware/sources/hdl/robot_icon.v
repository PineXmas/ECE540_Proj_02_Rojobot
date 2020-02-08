// robot_icon.v
// Thong & Deepen
//
// Handle Icon of the Rojobot

module robot_icon(
    input [11:0] pixel_row,
    input [11:0] pixel_column,
    input [7:0] LocX_reg,
    input [7:0] LocY_reg,
    input [7:0] BotInfo_reg,
    output [11:0] icon
);
    
  // NOTE: think about how to set transparent pixel
    
  assign icon = ((pixel_row >> 2) == LocY_reg) && ((pixel_column >> 2) == LocX_reg) ? 12'h0F0 : 12'h000;    
    
endmodule
