// mfp_nexys4_ddr.v
// January 1, 2017
//
// Instantiate the mipsfpga system and rename signals to
// match the GPIO, LEDs and switches on Digilent's (Xilinx)
// Nexys4 DDR board

// Outputs:
// 16 LEDs (IO_LED) 
// Inputs:
// 16 Slide switches (IO_Switch),
// 5 Pushbuttons (IO_PB): {BTNU, BTND, BTNL, BTNC, BTNR}
//

`include "mfp_ahb_const.vh"

module mfp_nexys4_ddr( 
                        input                   CLK100MHZ,
                        input                   CPU_RESETN,
                        input                   BTNU, BTND, BTNL, BTNC, BTNR, 
                        input  [`MFP_N_SW-1 :0] SW,
                        output [`MFP_N_LED-1:0] LED,
                        inout  [ 8          :1] JB,
                        input                   UART_TXD_IN,
                        
                        // 7-segment display
                        output [7:0]            AN,
                        output                  DP, CA, CB, CC, CD, CE, CF, CG,
                        
                        // VGA
                        output [3:0]          VGA_R, VGA_G, VGA_B,
                        output                VGA_HS, VGA_VS
                        );

  // Press btnCpuReset to reset the processor. 
        
  wire clk_50;
  wire clk_75;  
  wire tck_in, tck;
  
  // Debounced button & switch signals
  wire [5:0]            debounced_PB;
  wire [`MFP_N_SW-1 :0] debounced_SW;
  
  // Rojobot
  wire [7:0]  MotCtl_in;
  wire [7:0]  LocX_reg;
  wire [7:0]  LocY_reg;
  wire [7:0]  Sensors_reg;
  wire [7:0]  BotInfo_reg;
  wire        upd_sysregs;
  wire [11:0] icon;
  
  // Handshake flip-flop
  reg         H_BOT_UPDATE_SYNC;
  wire        IO_INT_ACK;
  
  // World map
  wire [13:0] worldmap_addr;
  wire [1:0]  worldmap_data;
  reg  [13:0] vid_addr;
  wire [1:0]  world_pixel;
  
  // VGA
  wire [11:0] pixel_column, pixel_row;
  wire        video_on;
  
  // --------------------------------------------------
  // INSTANCES
  // --------------------------------------------------
  
  clk_wiz_0 clk_wiz_0(
    .clk_in1(CLK100MHZ), 
    .clk_out1(clk_50), 
    .clk_out2(clk_75)
  );
  IBUF IBUF1(.O(tck_in),.I(JB[4]));
  BUFG BUFG1(.O(tck), .I(tck_in));
  
  // rojobot
  rojobot31_0 robot (
    .MotCtl_in(MotCtl_in),            // input wire [7 : 0] MotCtl_in
    .LocX_reg(LocX_reg),              // output wire [7 : 0] LocX_reg
    .LocY_reg(LocY_reg),              // output wire [7 : 0] LocY_reg
    .Sensors_reg(Sensors_reg),        // output wire [7 : 0] Sensors_reg
    .BotInfo_reg(BotInfo_reg),        // output wire [7 : 0] BotInfo_reg
    .worldmap_addr(worldmap_addr),    // output wire [13 : 0] worldmap_addr
    .worldmap_data(worldmap_data),    // input wire [1 : 0] worldmap_data
    .clk_in(clk_75),                  // input wire clk_in
    .reset(~(debounced_PB[5])),          // input wire reset
    .upd_sysregs(upd_sysregs),        // output wire upd_sysregs
    .Bot_Config_reg(debounced_SW)     // input wire [7 : 0] Bot_Config_reg
  );
  
  // handshake flip-flop
  always @ (posedge clk_50) begin
    if (IO_INT_ACK == 1'b1) begin
      H_BOT_UPDATE_SYNC <= 1'b0;
    end else if (upd_sysregs == 1'b1) begin
      H_BOT_UPDATE_SYNC <= 1'b1;
    end else begin
      H_BOT_UPDATE_SYNC <= H_BOT_UPDATE_SYNC;
    end
  end
  
  // world map
  world_map world_map(
    .clka(clk_75),
    .addra(worldmap_addr),
    .douta(worldmap_data),
    .clkb(clk_75),
    .addrb(vid_addr),
    .doutb(world_pixel)
  );
  
  // dtg
  dtg dtg(
    .clock(clk_75),
    .rst(~(debounced_PB[5])),
    .horiz_sync(VGA_HS),
    .vert_sync(VGA_VS), 
    .video_on(video_on),    
    .pixel_row(pixel_row), 
    .pixel_column(pixel_column)
  );
  
  // scaler
  always @(*) begin
    // keep as is, for now, scaling later
    vid_addr[6 :0] = pixel_column >> 2;
    vid_addr[13:7] = pixel_row >> 2;
  end
  
  // rojobot ICON
  robot_icon robot_icon(
    .pixel_row(pixel_row),
    .pixel_column(pixel_column),
    .LocX_reg(LocX_reg),
    .LocY_reg(LocY_reg),
    .BotInfo_reg(BotInfo_reg),
    .icon(icon)
  );
  
  colorizer colorizer(
    .icon(icon),
    .world_pixel(world_pixel),
    .video_on(video_on),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B)
  );
  
  // debouncer
  debounce debouncer(
    .clk(clk_50),  
    .pbtn_in({CPU_RESETN, BTNU, BTND, BTNL, BTNC, BTNR}),
    .switch_in(SW),
    .pbtn_db(debounced_PB),  
    .swtch_db(debounced_SW)
  );

  mfp_sys mfp_sys(
          .SI_Reset_N(debounced_PB[5]),
                    .SI_ClkIn(clk_50),
                    .HADDR(),
                    .HRDATA(),
                    .HWDATA(),
                    .HWRITE(),
					.HSIZE(),
                    .EJ_TRST_N_probe(JB[7]),
                    .EJ_TDI(JB[2]),
                    .EJ_TDO(JB[3]),
                    .EJ_TMS(JB[1]),
                    .EJ_TCK(tck),
                    .SI_ColdReset_N(JB[8]),
                    .EJ_DINT(1'b0),
                    .IO_Switch(debounced_SW),
                    .IO_PB(debounced_PB[4:0]),
                    .IO_LED(LED),
                    .UART_RX(UART_TXD_IN),
                    
                    .DISPENOUT(AN),
                    .DISPOUT({DP, CA, CB, CC, CD, CE, CF, CG}),
                    
                    .H_BOT_INFO({LocX_reg, LocY_reg, Sensors_reg, BotInfo_reg}),                    
                    .H_BOT_UPDATE_SYNC(H_BOT_UPDATE_SYNC),
                    .H_BOT_CTRL(MotCtl_in),
                    .H_INT_ACK(IO_INT_ACK)
                    );
          
endmodule
