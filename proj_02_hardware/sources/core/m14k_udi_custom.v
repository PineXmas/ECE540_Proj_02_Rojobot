// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//
//	Description: m14k_udi_custom
//                       custom User Defined Instruction Module
//                       User should modfiy this module to implement
//                       custom user-defined instructions.
//                       Except for the ports, the contents of this
//                       module should be completely replaced.
//
//	$Id: \$
//	mips_repository_id: m14k_udi_custom.mv, v 1.2 

//	mips_start_of_legal_notice
//	***************************************************************************
//	Unpublished work (c) MIPS Technologies, Inc.  All rights reserved. 
//	Unpublished rights reserved under the copyright laws of the United States
//	of America and other countries.
//	
//	MIPS TECHNOLOGIES PROPRIETARY / RESTRICTED CONFIDENTIAL - HEIGHTENED
//	STANDARD OF CARE REQUIRED AS PER CONTRACT
//	
//	This code is confidential and proprietary to MIPS Technologies, Inc. ("MIPS
//	Technologies") and may be disclosed only as permitted in writing by MIPS
//	Technologies.  Any copying, reproducing, modifying, use or disclosure of
//	this code (in whole or in part) that is not expressly permitted in writing
//	by MIPS Technologies is strictly prohibited.  At a minimum, this code is
//	protected under trade secret, unfair competition and copyright laws. 
//	Violations thereof may result in criminal penalties and fines.
//	
//	MIPS Technologies reserves the right to change the code to improve
//	function, design or otherwise.	MIPS Technologies does not assume any
//	liability arising out of the application or use of this code, or of any
//	error or omission in such code.  Any warranties, whether express,
//	statutory, implied or otherwise, including but not limited to the implied
//	warranties of merchantability or fitness for a particular purpose, are
//	excluded.  Except as expressly provided in any written license agreement
//	from MIPS Technologies, the furnishing of this code does not give recipient
//	any license to any intellectual property rights, including any patent
//	rights, that cover this code.
//	
//	This code shall not be exported, reexported, transferred, or released,
//	directly or indirectly, in violation of the law of any country or
//	international law, regulation, treaty, Executive Order, statute, amendments
//	or supplements thereto.  Should a conflict arise regarding the export,
//	reexport, transfer, or release of this code, the laws of the United States
//	of America shall be the governing law.
//	
//	This code may only be disclosed to the United States government
//	("Government"), or to Government users, with prior written consent from
//	MIPS Technologies.  This code constitutes one or more of the following:
//	commercial computer software, commercial computer software documentation or
//	other commercial items.  If the user of this code, or any related
//	documentation of any kind, including related technical data or manuals, is
//	an agency, department, or other entity of the Government, the use,
//	duplication, reproduction, release, modification, disclosure, or transfer
//	of this code, or any related documentation of any kind, is restricted in
//	accordance with Federal Acquisition Regulation 12.212 for civilian agencies
//	and Defense Federal Acquisition Regulation Supplement 227.7202 for military
//	agencies.  The use of this code by the Government is further restricted in
//	accordance with the terms of the license agreement(s) and/or applicable
//	contract terms and conditions covering this code from MIPS Technologies.
//	
//	
//	
//	***************************************************************************
//	mips_end_of_legal_notice
//	

`include "m14k_const.vh"

module m14k_udi_custom(
	UDI_ir_e,
	UDI_irvalid_e,
	UDI_rs_e,
	UDI_rt_e,
	UDI_endianb_e,
	UDI_kd_mode_e,
	UDI_kill_m,
	UDI_start_e,
	UDI_run_m,
	UDI_greset,
	UDI_gclk,
	UDI_gscanenable,
	UDI_rd_m,
	UDI_wrreg_e,
	UDI_ri_e,
	UDI_stall_m,
	UDI_present,
	UDI_honor_cee,
	UDI_toudi,
	UDI_fromudi);


`define M14K_SWP_GPR   5
`define M14K_SWP_ACC   4
`define M14K_SWP       3
`define M14K_SWP_MT    2
`define M14K_SWP_MF_L  1
`define M14K_SWP_MF_H  0   

        /* Inputs */
        input [31:0]    UDI_ir_e;           // full 32 bit Spec2 Instruction
        input           UDI_irvalid_e;      // Instruction reg. valid signal.

        input [31:0]    UDI_rs_e;           // edp_abus_e data from register file
        input [31:0]    UDI_rt_e;           // edp_bbus_e data from register file

	input 		UDI_endianb_e;      // Endian - 0=little, 1=big
	input 		UDI_kd_mode_e;      // Mode - 0=user, 1=kernel or debug

        input           UDI_kill_m;         // Kill signal
        input           UDI_start_e;        // mpc_run_ie signal to start the UDI.
        input 		UDI_run_m;          // mpc_UDI_run_m signal to qualify UDI_kill_m.

        input           UDI_greset;         // UDI_greset signal to reset state machine.
        input           UDI_gclk;           // Clock
        input 		UDI_gscanenable;

        /* Outputs */
        output [31:0]   UDI_rd_m;          // Result of the UDI in M stage
        output [4:0]    UDI_wrreg_e;       // Register File address written to
                                       // 5'b0 indicates not writing to 
                                       // register file.
        output          UDI_ri_e;          // Illegal Spec2 Instn.
        output          UDI_stall_m;       // Stall the pipeline. M stage signal
	output 		UDI_present;       // UDI module is present
	output 		UDI_honor_cee;     // UDI module has local state

    // external UDI signals
  input  [`M14K_UDI_EXT_TOUDI_WIDTH-1:0] UDI_toudi; // External input to UDI module
  output  [`M14K_UDI_EXT_FROMUDI_WIDTH-1:0] UDI_fromudi; // Output from UDI module to external system    

// BEGIN Wire declarations made by MVP
wire [31:0] /*[31:0]*/ hi_s2;
wire [31:0] /*[31:0]*/ UDI_rd_m;
wire [31:0] /*[31:0]*/ swp_gpr_s2;
wire [31:0] /*[31:0]*/ swp_hi_s1;
wire run_udi_e;
wire swp;
wire [31:0] /*[31:0]*/ swp_hi_s2;
wire [`M14K_UDI_EXT_FROMUDI_WIDTH-1:0] /*[0:0]*/ UDI_fromudi;
wire [31:0] /*[31:0]*/ swp_lo_s2;
wire UDI_stall_m;
wire UDI_stall_m_reg;
wire [31:0] /*[31:0]*/ swp_lo_s1;
wire [31:0] /*[31:0]*/ hi;
wire [31:0] /*[31:0]*/ lo;
wire [4:0] /*[4:0]*/ UDI_wrreg_e;
wire spec2_e;
wire run_udi_s1;
wire [5:0] /*[5:0]*/ inst_e;
wire valid_udi_e;
wire swp_mf_l;
wire swp_mf_h;
wire [31:0] /*[31:0]*/ lo_s2;
wire udi_inst;
wire hilo_write_s2;
wire udi_in_m;
wire UDI_ri_e;
wire [5:0] /*[5:0]*/ inst_s2;
wire UDI_present;
wire swp_acc;
wire UDI_honor_cee;
wire [5:0] /*[5:0]*/ inst_s1;
wire [31:0] /*[31:0]*/ rs_s1;
wire swp_gpr;
wire run_udi_s2;
wire [31:0] /*[31:0]*/ rt_s1;
wire swp_mt;
// END Wire declarations made by MVP

    
assign UDI_fromudi[`M14K_UDI_EXT_FROMUDI_WIDTH-1:0] = {`M14K_UDI_EXT_FROMUDI_WIDTH{1'b0}};

    
/*   
 This pipelined UDI module includes result storage (for use by following UDI instructions).
    The internal HI/LO registers are not written until the instruction is guaranteed not 
    to be killed. 
    The UDI_stall_m signal stalls the processor when 1) the current UDI instruction destination
    is a GPR, and it needs more than one cycle to complete 2) the current UDI instruction
    requires a previous UDI's results, and it needs the data before the previous UDI instruction
    has it available (similar to an MFHI/MULT confict).
    
 
 m14k_udi_custom            
                    UDI - pipe w/ hi/lo
  ===============================================
  %     E        S1          S2       S3        %
  %  decode | bit swap | more swap _|_hi/lo     %
  %   -->   |    ----> |  ------>  || |         %
  %   |     | |        |           ||_|         %
  %   |legal| |result  |        <---|-*accum    %
  %   |       |to gpr0                          %
  ===============================================
      |       |       MPC
  ===============================================
  %   |  E    |   M           A         W       %
  %   *---> | *----->  |  ------>   | "write to %
  %         |          |            |  gpr 0"   %
  %                                             %
  ===============================================
  
*/ 
   
// UDI_present: Indicates that at least one UDI is implemented
	assign UDI_present = 1'b1;

// UDI_honor_cee: Indicates that UDI block has local state
	assign UDI_honor_cee = 1'b1;

/*   
 UDI instructions: 
        1a) move results from hi to gpr.
          SWPMFH
          IR[5:0] = 6'b010010
        2) move results from lo to gpr.
          SWPMFL
          IR[5:0] = 6'b010011
        3) move gpr data to hi/lo.
          SWPMT : hi = rs[31:0] ; lo = rt[31:0]
          IR[5:0] = 6'b010100
        4) store results in hi/lo
          SWP :   hi = { rs[31:16], rt[31:16] }; lo = { rt{15:0], rs[15:0] } 
          IR[5:0] = 6'b010101
        5) use results from hi/lo in calculation. place results in hi/lo.
          SWPACC: hi = { hi[15:0], rt[31:16] }; lo = { lo[15:0], rs[15:0] } 
          IR[5:0] = 6'b010110
        6) use results from hi/lo in calculation. place results in gpr.   
          SWPGPR: gpr = { hi[15:8], rt[15:8], lo[15:8], rs[15:8] }         
          IR[5:0] = 6'b010111
*/ 
// Instruction validity.
        assign udi_inst = (UDI_ir_e[5:4] == 2'b01);
   
        assign swp_mf_h = udi_inst && (UDI_ir_e[3:0] == 4'b0010);
        assign swp_mf_l = udi_inst && (UDI_ir_e[3:0] == 4'b0011);
        assign swp_mt   = udi_inst && (UDI_ir_e[3:0] == 4'b0100);
        assign swp      = udi_inst && (UDI_ir_e[3:0] == 4'b0101);
        assign swp_acc  = udi_inst && (UDI_ir_e[3:0] == 4'b0110);
        assign swp_gpr  = udi_inst && (UDI_ir_e[3:0] == 4'b0111);

        assign inst_e[5:0] = {swp_gpr, swp_acc, swp, swp_mt, swp_mf_l, swp_mf_h};   
   
        assign valid_udi_e = |(inst_e[5:0]);
        assign spec2_e = (UDI_ir_e[31:26] == 6'b011100);

// Fully decoded Run signal.
        assign run_udi_e = valid_udi_e && spec2_e &&
                    UDI_irvalid_e && UDI_start_e;

// The Spec2 part of it is checked in control block.
        assign UDI_ri_e = !valid_udi_e ;

// Rd field of instruction. 
	assign UDI_wrreg_e[4:0] = (inst_e[`M14K_SWP_MF_H] || inst_e[`M14K_SWP_MF_L] || inst_e[`M14K_SWP_GPR]) ? 
		       UDI_ir_e[15:11] : 5'b0; 

// Only instructions eventually writing to GPR have to stall, and even then
//      only for one cycle.
	assign UDI_stall_m = (inst_s1[`M14K_SWP_GPR] || inst_s1[`M14K_SWP_MF_H] || inst_s1[`M14K_SWP_MF_L]) && !UDI_stall_m_reg
		  && run_udi_s1; // random stalls could prevent run_udi_e, so need udi_s1 here
        mvp_register #(1) _UDI_stall_m_reg(UDI_stall_m_reg,UDI_gclk, UDI_stall_m);

// End of e-stage. Register input data for use in s1-stage.
        mvp_cregister_wide #(32) _rs_s1_31_0_(rs_s1[31:0],UDI_gscanenable, run_udi_e, UDI_gclk, UDI_rs_e[31:0]);
        mvp_cregister_wide #(32) _rt_s1_31_0_(rt_s1[31:0],UDI_gscanenable, run_udi_e, UDI_gclk, UDI_rt_e[31:0]);
        mvp_register #(1) _run_udi_s1(run_udi_s1,UDI_gclk, run_udi_e);
        mvp_register #(6) _inst_s1_5_0_(inst_s1[5:0],UDI_gclk, inst_e[5:0]);  // make into creg w/ run_udi_e

        // udi in m-stage in mpc. (run_udi_s2 is independent of normal pipe. udi_in_m is used
        //     to verify UDI_kill_m is killing a udi instruction).
        mvp_cregister #(1) _udi_in_m(udi_in_m,UDI_start_e || UDI_run_m, UDI_gclk, run_udi_e);

        assign swp_hi_s1[31:0] = {rs_s1[31:16], rt_s1[31:16]};
        assign swp_lo_s1[31:0] = {rt_s1[15:0] , rs_s1[15:0] };

// End of s1-stage. Register s1-stage data for use in s2-stage.
        mvp_cregister_wide #(32) _swp_hi_s2_31_0_(swp_hi_s2[31:0],UDI_gscanenable, run_udi_s1, UDI_gclk, swp_hi_s1[31:0]);
        mvp_cregister_wide #(32) _swp_lo_s2_31_0_(swp_lo_s2[31:0],UDI_gscanenable, run_udi_s1, UDI_gclk, swp_lo_s1[31:0]);
        // used to commit udi result to hi/lo when we know it can't be killed anymore.
        mvp_register #(1) _run_udi_s2(run_udi_s2,UDI_gclk, UDI_run_m && !UDI_kill_m && udi_in_m); 
        mvp_cregister_wide #(6) _inst_s2_5_0_(inst_s2[5:0],UDI_gscanenable, run_udi_s1, UDI_gclk, inst_s1[5:0]);

        assign hi_s2[31:0] = (inst_s2[`M14K_SWP_GPR] || inst_s2[`M14K_SWP_ACC]) ? {hi[15:0], swp_hi_s2[15:0]} :
		       inst_s2[`M14K_SWP_MT] ? {swp_hi_s2[31:16], swp_lo_s2[15:0]} : // rs
		       swp_hi_s2[31:0];
        assign lo_s2[31:0] = (inst_s2[`M14K_SWP_GPR] || inst_s2[`M14K_SWP_ACC]) ? {lo[15:0], swp_lo_s2[15:0]} :
		       inst_s2[`M14K_SWP_MT] ? {swp_hi_s2[15:0], swp_lo_s2[31:16]} : // rt
		       swp_lo_s2[31:0];

// Hi/Lo are only written when the instruction can no longer be interrupted.
        assign hilo_write_s2 = inst_s2[`M14K_SWP_MT] || inst_s2[`M14K_SWP] || inst_s2[`M14K_SWP_ACC];
        mvp_cregister_wide #(32) _hi_31_0_(hi[31:0],UDI_gscanenable, run_udi_s2 && hilo_write_s2, UDI_gclk, hi_s2[31:0]);
        mvp_cregister_wide #(32) _lo_31_0_(lo[31:0],UDI_gscanenable, run_udi_s2 && hilo_write_s2, UDI_gclk, lo_s2[31:0]);

// Result data.   
	assign UDI_rd_m[31:0] = inst_s2[`M14K_SWP_MF_L] ? lo[31:0] :  // s2-stage
		     inst_s2[`M14K_SWP_MF_H] ? hi[31:0] :  // s2-stage
		     swp_gpr_s2[31:0]; // s2-stage
   
        assign swp_gpr_s2 [31:0] = {hi_s2[31:24], hi_s2[15:8], lo_s2[31:24], lo_s2[15:8]};
                      // hi[15:8]   // rt[31:24]  // lo[15:8]    // rs[15:8]

endmodule 

