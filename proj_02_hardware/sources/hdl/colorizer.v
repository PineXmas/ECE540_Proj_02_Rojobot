// colorizer.v
// Thong & Deepen
//
// Determine the color for a given pixel position


module colorizer(
    input [11:0]      icon,
    input [11:0]      map_color,
    input [1:0]       world_pixel,
    input             video_on,
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B
);

  // DECLARATIONS
  reg [11:0] world_color;
  
  // determine world color based on the world pixel
  always @(*) begin
    case (world_pixel)
      2'b00:    world_color = 12'hFFF;
      2'b01:    world_color = 12'h000;
      2'b10:    world_color = 12'hF00;
      default:  world_color = 12'h000;
    endcase
  end

  // determine between icon color or world color
  always @(*) begin
    if (~video_on) begin
      {VGA_R, VGA_G, VGA_B} = 12'h000;
    end
    else begin
      {VGA_R, VGA_G, VGA_B} = icon ? icon : world_color;
    end
  end

endmodule
