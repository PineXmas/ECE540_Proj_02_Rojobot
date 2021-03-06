// mfp_ahb.v
// 
// January 1, 2017
//
// AHB-lite bus module with 3 slaves: boot RAM, program RAM, and
// GPIO (memory-mapped I/O: switches and LEDs from the FPGA board).
// The module includes an address decoder and multiplexer (for 
// selecting which slave module produces HRDATA).

`include "mfp_ahb_const.vh"

 
module mfp_ahb
(
    input                       HCLK,
    input                       HRESETn,
    input      [ 31         :0] HADDR,
    input      [  2         :0] HBURST,
    input                       HMASTLOCK,
    input      [  3         :0] HPROT,
    input      [  2         :0] HSIZE,
    input      [  1         :0] HTRANS,
    input      [ 31         :0] HWDATA,
    input                       HWRITE,
    output     [ 31         :0] HRDATA,
    output                      HREADY,
    output                      HRESP,
    input                       SI_Endian,

// memory-mapped I/O
    input      [`MFP_N_SW-1 :0] IO_Switch,
    input      [`MFP_N_PB-1 :0] IO_PB,
    output     [`MFP_N_LED-1:0] IO_LED,    
    
// 7-segment display
    output [7:0]                DISPENOUT,
    output [7:0]                DISPOUT,
    
// rojobot
    input [31:0]                H_BOT_INFO,
    input                       H_BOT_UPDATE_SYNC,
    output [7:0]                H_BOT_CTRL,
    output                      H_INT_ACK
);


  wire [31:0] HRDATA2, HRDATA1, HRDATA0, HRDATA_ROJOBOT;
  wire [`N_BUS_DEVICES-1 : 0] HSEL;
  reg  [`N_BUS_DEVICES-1 : 0] HSEL_d;

  assign HREADY = 1;
  assign HRESP = 0;
	
  // Delay select signal to align for reading data
  always @(posedge HCLK)
    HSEL_d <= HSEL;

  // Module 0 - boot ram
  mfp_ahb_b_ram mfp_ahb_b_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA0, HSEL[0]);
  // Module 1 - program ram
  mfp_ahb_p_ram mfp_ahb_p_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA1, HSEL[1]);
  // Module 2 - GPIO
  mfp_ahb_gpio mfp_ahb_gpio(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[2], 
                            HRDATA2, IO_Switch, IO_PB, IO_LED);
  
  // Module 3 - 7 Segment Display
  mfp_ahb_sevenseg mfp_ahb_sevenseg(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HADDR(HADDR[7:0]),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSEL(HSEL[3]),
    .DISPENOUT(DISPENOUT),
    .DISPOUT(DISPOUT)
  );

  // Module 4 - Rojobot IO
  mfp_ahb_rojobot_io mfp_ahb_rojobot_io(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HADDR(HADDR[7:0]),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSEL(HSEL[4]),
    .HTRANS(HTRANS),
    .H_BOT_INFO(H_BOT_INFO),
    .H_BOT_UPDATE_SYNC(H_BOT_UPDATE_SYNC),
    .H_BOT_CTRL(H_BOT_CTRL),
    .H_INT_ACK(H_INT_ACK),     
    .HRDATA(HRDATA_ROJOBOT)
  );
  

  ahb_decoder ahb_decoder(HADDR, HSEL);
  ahb_mux ahb_mux(HCLK, HSEL_d, HRDATA2, HRDATA1, HRDATA0, HRDATA_ROJOBOT, HRDATA);

endmodule


module ahb_decoder
(
    input  [31:0]                   HADDR,
    output [`N_BUS_DEVICES-1 : 0]   HSEL
);

  // Decode based on most significant bits of the address
  assign HSEL[0] = (HADDR[28:22] == `H_RAM_RESET_ADDR_Match);   // 128 KB RAM  at 0xbfc00000 (physical: 0x1fc00000)
  assign HSEL[1] = (HADDR[28]    == `H_RAM_ADDR_Match);         // 256 KB RAM at 0x80000000 (physical: 0x00000000)
  assign HSEL[2] = (HADDR[28:22] == `H_LED_ADDR_Match);         // GPIO at 0xbf800000 (physical: 0x1f800000)
  assign HSEL[3] = (HADDR[31:8]  == `H_7_SEG_ADDR_Match);       // 7-Seg at 0xBF70_0000 (physical: 0x1F70_0000)
  assign HSEL[4] = (HADDR[31:8]  == `H_ROJOBOT_ADDR_Match);     // Rojobot IO ports at 0xBF80_0000 (physical: 0x1F80_0000)
endmodule


module ahb_mux
(
    input                             HCLK,
    input      [`N_BUS_DEVICES-1 : 0] HSEL,
    input      [31:0]                 HRDATA2, HRDATA1, HRDATA0, HRDATA_ROJOBOT,
    output reg [31:0]                 HRDATA
);

    always @(*)
      casez (HSEL)
	      `N_BUS_DEVICES'b????1:     HRDATA = HRDATA0;
	      `N_BUS_DEVICES'b???10:     HRDATA = HRDATA1;
	      `N_BUS_DEVICES'b??100:     HRDATA = HRDATA2;
	      `N_BUS_DEVICES'b?1000:     HRDATA = HRDATA1;           // the 7-Seg is not readable, for now (Project 1)
	      `N_BUS_DEVICES'b10000:     HRDATA = HRDATA_ROJOBOT;    // the Rojobot is readable (bot-info & update-sync)
	      default:     HRDATA = HRDATA1;
      endcase
endmodule

