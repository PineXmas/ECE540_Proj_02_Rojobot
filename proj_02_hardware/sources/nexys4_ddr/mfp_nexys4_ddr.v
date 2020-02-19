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
  wire [1:0]  worldmap_data, worldmap_data_part_1, worldmap_data_lr, worldmap_data_loop;
  wire [13:0] vid_addr;
  wire [1:0]  world_pixel, world_pixel_part_1, world_pixel_lr, world_pixel_loop;
  wire [11:0] map_color;
  
  // Title
  wire [11:0] title_color;
  
  // VGA
  wire [11:0] pixel_column, pixel_row;
  wire        video_on;
  
  // Scaler
  wire [6:0]  world_row, world_column;
  wire        out_of_map;
  
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
  
  // world map part 1
  world_map world_map(
    .clka(clk_75),
    .addra(worldmap_addr),
    .douta(worldmap_data_part_1),
    .clkb(clk_75),
    .addrb(vid_addr),
    .doutb(world_pixel_part_1)
  );
  
  // world map lr
  world_map_lr world_map_lr(
    .clka(clk_75),
    .addra(worldmap_addr),
    .douta(worldmap_data_lr),
    .clkb(clk_75),
    .addrb(vid_addr),
    .doutb(world_pixel_lr)
  );
  
  // world map loop
  world_map_loop world_map_loop(
    .clka(clk_75),
    .addra(worldmap_addr),
    .douta(worldmap_data_loop),
    .clkb(clk_75),
    .addrb(vid_addr),
    .doutb(world_pixel_loop)
  );
  
  // mux to select map based on the SW
  assign {worldmap_data, world_pixel} =
    debounced_SW[14] ? {worldmap_data_lr, world_pixel_lr} : (
      debounced_SW[13] ? {worldmap_data_loop, world_pixel_loop} : {worldmap_data_part_1, world_pixel_part_1}
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
  vga_scaler_v2 vga_scaler_v2(
    .world_row(world_row),
    .world_column(world_column),
    .pixel_row(pixel_row),
    .pixel_column(pixel_column),
    .vid_addr(vid_addr),
    .out_of_map(out_of_map)
  );
  
  // rojobot ICON  
  robot_icon_v2 robot_icon_v2(
    .clk(clk_75),
    .reset(~(debounced_PB[5])),
    .pixel_row(pixel_row),
    .pixel_column(pixel_column),
    .LocX_reg(LocX_reg),
    .LocY_reg(LocY_reg),
    .BotInfo_reg(BotInfo_reg),
    .icon(icon)
  );
  
  // map colorizer
  map_colorizer map_colorizer(
    .pixel_row(pixel_row),
    .pixel_column(pixel_column),
    .map_value(world_pixel),
    .map_color(map_color)
  );
  
  // title colorizer
  title_colorizer title_colorizer(
    .clk(clk_75),
    .pixel_row(pixel_row),
    .pixel_column(pixel_column),
    .title_color(title_color)
  );
  
  // colorizer
  colorizer_v2 colorizer_v2(
    .icon(icon),
    .map_color(map_color),
    .title_color(title_color),
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

  //MIPSfpga
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
