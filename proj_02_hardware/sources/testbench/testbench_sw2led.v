// testbench.v
// 31 May 2014
//
// Drive the mipsfpga_sys module for simulation testing

`timescale 100ps/1ps

`include "mfp_ahb_const.vh"

module testbench_sw2led;

    reg                    SI_Reset_N, SI_ClkIn;
    wire [31           :0] HADDR, HRDATA, HWDATA;
    wire                   HWRITE;
	wire [ 2           :0] HSIZE;
    reg                    EJ_TRST_N_probe, EJ_TDI; 
    wire                   EJ_TDO;
    reg                    SI_ColdReset_N;
    reg                    EJ_TMS, EJ_TCK, EJ_DINT;
    reg  [`MFP_N_SW-1  :0] IO_Switch;
    wire [          4  :0] IO_PB;
    wire [`MFP_N_LED-1 :0] IO_LED;
    reg                    UART_RX;
					
    mfp_sys sys (.SI_Reset_N(SI_Reset_N),
                 .SI_ClkIn(SI_ClkIn),
                 .HADDR(HADDR), 
                 .HRDATA(HRDATA), 
                 .HWDATA(HWDATA), 
                 .HWRITE(HWRITE), 
                 .HSIZE(HSIZE),
                 .EJ_TRST_N_probe(EJ_TRST_N_probe), 
                 .EJ_TDI(EJ_TDI), 
                 .EJ_TDO(EJ_TDO), 
                 .EJ_TMS(EJ_TMS), 
                 .EJ_TCK(EJ_TCK), 
                 .SI_ColdReset_N(SI_ColdReset_N), 
                 .EJ_DINT(EJ_DINT),
                 .IO_Switch(IO_Switch), 
                 .IO_PB(IO_PB), 
                 .IO_LED(IO_LED), 
                 .UART_RX(UART_RX)
    );

    initial
    begin
        SI_ClkIn = 0;
        EJ_TRST_N_probe = 0; EJ_TDI = 0; EJ_TMS = 0; EJ_TCK = 0; EJ_DINT = 0;
        UART_RX = 1;
        SI_ColdReset_N = 1;

        forever
            #50 SI_ClkIn = ~ SI_ClkIn;
    end

    initial
    begin
        IO_Switch = `MFP_N_SW'habcd; # 100;
        SI_Reset_N  <= 0;
        repeat (100)  @(posedge SI_ClkIn);
        SI_Reset_N  <= 1;
        repeat (10)  @(posedge SI_ClkIn);
        IO_Switch = `MFP_N_SW'habcd;
        repeat (100)  @(posedge SI_ClkIn);
        IO_Switch = `MFP_N_SW'h1234;
        repeat (100)  @(posedge SI_ClkIn);
        IO_Switch = `MFP_N_SW'h0011;
        repeat (100)  @(posedge SI_ClkIn);
        IO_Switch = `MFP_N_SW'hffff;
        repeat (100)  @(posedge SI_ClkIn);
        IO_Switch = `MFP_N_SW'haaaa;
		repeat (100)  @(posedge SI_ClkIn);

        $stop;
    end

    initial
    begin
        $dumpvars;
        $timeformat (-9, 1, "ns", 10);
    end
    
endmodule


