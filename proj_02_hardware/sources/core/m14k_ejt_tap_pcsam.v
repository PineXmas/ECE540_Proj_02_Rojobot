// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//
//      Description: m14k_ejt_tap_pcsam
//      EJTAG TAP PC SAMPLE module 
//
//      $Id: \$
//      mips_repository_id: m14k_ejt_tap_pcsam.mv, v 1.4 
//
//      mips_start_of_legal_notice
//      **********************************************************************
//      Unpublished work (c) MIPS Technologies, Inc.  All rights reserved. 
//      Unpublished rights reserved under the copyright laws of the United
//      States of America and other countries.
//      
//      MIPS TECHNOLOGIES PROPRIETARY / RESTRICTED CONFIDENTIAL - HEIGHTENED
//      STANDARD OF CARE REQUIRED AS PER CONTRACT
//      
//      This code is confidential and proprietary to MIPS Technologies, Inc.
//      ("MIPS Technologies") and may be disclosed only as permitted in
//      writing by MIPS Technologies.  Any copying, reproducing, modifying,
//      use or disclosure of this code (in whole or in part) that is not
//      expressly permitted in writing by MIPS Technologies is strictly
//      prohibited.  At a minimum, this code is protected under trade secret,
//      unfair competition and copyright laws.	Violations thereof may result
//      in criminal penalties and fines.
//      
//      MIPS Technologies reserves the right to change the code to improve
//      function, design or otherwise.	MIPS Technologies does not assume any
//      liability arising out of the application or use of this code, or of
//      any error or omission in such code.  Any warranties, whether express,
//      statutory, implied or otherwise, including but not limited to the
//      implied warranties of merchantability or fitness for a particular
//      purpose, are excluded.	Except as expressly provided in any written
//      license agreement from MIPS Technologies, the furnishing of this code
//      does not give recipient any license to any intellectual property
//      rights, including any patent rights, that cover this code.
//      
//      This code shall not be exported, reexported, transferred, or released,
//      directly or indirectly, in violation of the law of any country or
//      international law, regulation, treaty, Executive Order, statute,
//      amendments or supplements thereto.  Should a conflict arise regarding
//      the export, reexport, transfer, or release of this code, the laws of
//      the United States of America shall be the governing law.
//      
//      This code may only be disclosed to the United States government
//      ("Government"), or to Government users, with prior written consent
//      from MIPS Technologies.  This code constitutes one or more of the
//      following: commercial computer software, commercial computer software
//      documentation or other commercial items.  If the user of this code, or
//      any related documentation of any kind, including related technical
//      data or manuals, is an agency, department, or other entity of the
//      Government, the use, duplication, reproduction, release, modification,
//      disclosure, or transfer of this code, or any related documentation of
//      any kind, is restricted in accordance with Federal Acquisition
//      Regulation 12.212 for civilian agencies and Defense Federal
//      Acquisition Regulation Supplement 227.7202 for military agencies.  The
//      use of this code by the Government is further restricted in accordance
//      with the terms of the license agreement(s) and/or applicable contract
//      terms and conditions covering this code from MIPS Technologies.
//      
//      
//      
//      **********************************************************************
//      mips_end_of_legal_notice
//

`include "m14k_const.vh"


module m14k_ejt_tap_pcsam(
	gclk,
	greset,
	gscanenable,
	cpz_epc_w,
	mpc_cleard_strobe,
	mpc_exc_w,
	mmu_asid,
	cpz_guestid,
	icc_pm_icmiss,
	edp_iva_i,
	pc_sync_period,
	pc_sync_period_diff,
	pcse,
	new_pcs_ack_tck,
	pc_im,
	pcsam_val,
	new_pcs_gclk,
	pcs_present);



// Global Signals
  input         gclk;
  input   	greset;         // reset
  input         gscanenable;         

  
// Signals from ALU  
  input [31:0]  cpz_epc_w;      // PC of the graduating instruction from W stage
  input		mpc_cleard_strobe; //monitoring bit for instruction completion
  input		mpc_exc_w;      //Exception in W-stage
  input [7:0]   mmu_asid;
  input [7:0]   cpz_guestid;
  input         icc_pm_icmiss;  // Perf. monitor I$ miss 
  input  [31:0] edp_iva_i;      // Instn virtual address (I-stage)
  
// Ej Signals  
  input [2:0]   pc_sync_period;       // 3 bits from debug ctl register which 
                                      // specify the sync period
  input         pc_sync_period_diff;  // indicates write to pc sync period 
                                      // used to reset the pc sample counter
  input         pcse;                 // PC Sample Write Enable Bit
  input         new_pcs_ack_tck;      // tck domain accepts the new pcsam_val
  input         pc_im;                // config PC sampling to capture all excuted addresses or only those that miss the instruction cache
  // Outputs  
  output [55:0] pcsam_val; // PC Value which has been sampled
  output        new_pcs_gclk;    // gclk domain has a new pcsam_val
  output	pcs_present;

// BEGIN Wire declarations made by MVP
wire pcse_deasserted;
wire pcse_reg;
wire [55:0] /*[55:0]*/ sampled_pc;
wire [55:0] /*[55:0]*/ pcsam_reg;
wire [55:0] /*[55:0]*/ pcsam_imiss;
wire [12:0] /*[12:0]*/ counter;
wire counter_reset;
wire pcs_present;
wire pending_sample_pc;
wire counter_overflow;
wire sample_en_pc;
// END Wire declarations made by MVP


  wire		sample_st_send;
  wire          inst_complete_w;
  wire		sample_st_pend;
  wire		sync_wakeup;
  assign pcs_present = 1'b1;
   mvp_cregister_wide #(56) _pcsam_reg_55_0_(pcsam_reg[55:0],gscanenable, inst_complete_w && pcse, gclk,
                                     {cpz_guestid[7:0],8'b0,mmu_asid[7:0], cpz_epc_w[31:0]});
   mvp_cregister_wide #(56) _pcsam_imiss_55_0_(pcsam_imiss[55:0],gscanenable, pc_im && icc_pm_icmiss && pcse, gclk,
				    {cpz_guestid[7:0],8'b0,mmu_asid[7:0], edp_iva_i[31:0]});
   assign sampled_pc[55:0] = pc_im ? pcsam_imiss[55:0] : pcsam_reg[55:0];
   mvp_register #(1) _pcse_reg(pcse_reg, gclk, pcse);
   assign pcse_deasserted = !pcse && pcse_reg;


   // counter related logic to detect overflow and increment counter
   // pcse starts/stops the counter, but when its disabled, we take an extra cycle to clear the count
   assign counter_overflow = (counter[12:5] == (8'd1 << pc_sync_period));
   assign counter_reset = greset || counter_overflow || pcse_deasserted  || pc_sync_period_diff;
   mvp_cregister_wide #(13) _counter_12_0_(counter[12:0],gscanenable,  pcse_reg || greset, gclk,
                                  counter_reset ? 13'd1 : counter[12:0] + 13'd1);

   // When counter fires, set pending_sample until it is sampled
   mvp_cregister #(1) _pending_sample_pc(pending_sample_pc,greset || counter_overflow  || sample_en_pc, gclk,
                              !greset && counter_overflow  && !sample_en_pc);

   // Enable sampling only when there is something valid to sample and when we are allowed to change the value
   // NOTE: We *are* allowed to change the sample even if ack is asserted - we just cant transfer to tck until the protocol has completed.
   assign inst_complete_w = mpc_cleard_strobe && !mpc_exc_w ;
   assign sample_en_pc = (pending_sample_pc || counter_overflow ) && !sample_st_send;

   m14k_ejt_async_snd #(56,1) pcsam_async_snd (
                                              .gscanenable(gscanenable),
                                              .gclk( gclk),
                                              .gfclk( gclk),            // Do not need wakeup logic on gfclk
                                              .reset(greset),
                                              .reset_unsync(1'b0),
                                              .sync_data_in(sampled_pc[55:0]),
                                              .sync_sample(sample_en_pc),
                                              .sync_sample_st_send(sample_st_send),
                                              .sync_sample_st_pend(sample_st_pend),
                                              .sync_wakeup(sync_wakeup),
                                              .async_data_out(pcsam_val),
                                              .async_data_rdy(new_pcs_gclk),
                                              .async_data_ack(new_pcs_ack_tck)
                                              );


//verilint 528 off      // Variable set but not used
wire unused_ok;
  assign unused_ok = &{1'b0,
                sync_wakeup,
                sample_st_pend};
//verilint 528 on       // Variable set but not used
  
endmodule
