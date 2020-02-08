// mfp_ahb_rojobot_io.v
// Thong & Deepen
//
// Handle IO of Rojobot

`include "mfp_ahb_const.vh"

module mfp_ahb_rojobot_io(
    input                        HCLK,
    input                        HRESETn,
    input      [  7          :0] HADDR,     // only care about the 8 least significant bits
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,
    input                        HTRANS,
    input      [ 31          :0] H_BOT_INFO,        // robot info from the robot
    input                        H_BOT_UPDATE_SYNC, // update sync from the handshake flip-flop
    output reg [  7          :0] H_BOT_CTRL,        // control sent to the robot
    output reg                   H_INT_ACK,         // int ack sent to the handshake flip-flop
    output reg [ 31          :0] HRDATA
);

  // DECLARATIONS
  reg [7:0]   HADDR_d;
  reg         HWRITE_d;
  reg         HSEL_d;
  reg         HTRANS_d;
  wire        we;

  // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
  always @ (posedge HCLK) 
  begin
    HADDR_d  <= HADDR;
    HWRITE_d <= HWRITE;
    HSEL_d   <= HSEL;
    HTRANS_d <= HTRANS;
  end
  
  // determine write enable signal
  assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;
  
  // write data
  always @ (posedge HCLK, negedge HRESETn)
  begin
    if (~HRESETn) begin
      H_INT_ACK   <= 1'b0;
      H_BOT_CTRL  <= 8'h00;
    end
    else if (HSEL_d & HWRITE_d) begin
      case (HADDR_d)
        // bot control
        8'h10: H_BOT_CTRL <= HWDATA[7:0];
        
        // int ack
        8'h18: H_INT_ACK  <= HWDATA[0];
      endcase
    end
  end
  
  // read data
  always @ (posedge HCLK, negedge HRESETn)
    begin
      if (~HRESETn) begin
        HRDATA <= 32'h00_00_00_00;
      end
      else begin
        case (HADDR)
          // bot info
          8'h0C: HRDATA <= H_BOT_INFO;
          
          // update sync
          8'h14: HRDATA <= {31'h00_00_00_00, H_BOT_UPDATE_SYNC};
        endcase
      end
    end
    
endmodule
