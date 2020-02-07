// mfp_ahb_7_seg.v
// Thong Doan
//
// 7 Segment Display for 
// Digilent's (Xilinx) Nexys4-DDR board

`include "mfp_ahb_const.vh"

module mfp_ahb_sevenseg(
    input                        HCLK,
    input                        HRESETn,
    input      [  7          :0] HADDR,     // only care about the 8 least significant bits
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,
    output [7:0] DISPENOUT,
    output [7:0] DISPOUT
);

  // DECLARATIONS
  reg [7:0]   HADDR_d;
  reg         HWRITE_d;
  reg         HSEL_d;
  reg [7:0]   H_DIGIT_ENS;    // digit enable registers
  reg [63:0]  H_DIGIT_REGS;   // digit data registers
  reg [7:0]   H_DEC_POINTS;   // dec. point registers
  
  // INSTANCE: the display timer (the decoder is included inside the timer)
  mfp_ahb_sevensegtimer display_timer(
    .clk(HCLK),
    .resetn(HRESETn),
    .EN(H_DIGIT_ENS),
    .DIGITS(H_DIGIT_REGS),
    .dp(H_DEC_POINTS),
    .DISPENOUT(DISPENOUT),
    .DISPOUT(DISPOUT)
  );

  // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
  always @ (posedge HCLK) 
  begin
    HADDR_d  <= HADDR;
    HWRITE_d <= HWRITE;
    HSEL_d   <= HSEL;
  end
  
  // write data
  always @ (posedge HCLK, negedge HRESETn)
  begin
    if (~HRESETn) begin
      H_DIGIT_ENS   <= 8'hF0;
      H_DIGIT_REGS  <= 64'h0000_0000_0000_0000;
      H_DEC_POINTS  <= 8'hF7;
    end
    else if (HWRITE_d & HSEL_d) begin
      case (HADDR_d)
        // digit enables
        8'h00: H_DIGIT_ENS          <= HWDATA[7:0];
        
        // digit values
        8'h04: H_DIGIT_REGS[63:32]  <= HWDATA;
        8'h08: H_DIGIT_REGS[31: 0]  <= HWDATA;
        
        // dec point enables
        8'h0C: H_DEC_POINTS         <= HWDATA[7:0];
      endcase
    end
  end
endmodule
