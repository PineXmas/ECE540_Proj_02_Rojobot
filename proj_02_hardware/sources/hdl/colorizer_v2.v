// colorizer_v2.v
// Thong & Deepen
//
// Determine which color to display b/w robot, map & title, using layer-concept


module colorizer_v2(
    input [11:0]      icon,
    input [11:0]      map_color,
    input [11:0]      title_color,
    input             video_on,
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B
);

  // determine between icon color or world color
  always @(*) begin
    if (~video_on) begin
      {VGA_R, VGA_G, VGA_B} = 12'h000;
    end
    else begin
      {VGA_R, VGA_G, VGA_B} = title_color ? title_color : (icon ? icon : map_color);
    end
  end

endmodule
