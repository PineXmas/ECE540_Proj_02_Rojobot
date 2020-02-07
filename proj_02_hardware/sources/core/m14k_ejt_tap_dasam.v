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
//      mips_repository_id: m14k_ejt_tap_dasam.mv, v 1.4 
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


module m14k_ejt_tap_dasam(
	gclk,
	greset,
	gscanenable,
	cpz_guestid,
	mmu_asid,
	mmu_dva_m,
	dcc_dvastrobe,
	pc_sync_period,
	pc_sync_period_diff,
	new_das_ack_tck,
	dasq,
	dase,
	brk_d_trig,
	dasam_val,
	new_das_gclk,
	das_present);



// Global Signals
  input         gclk;
  input   	greset;         // reset
  input         gscanenable;         

  
// Signals from ALU  
  input  [7:0]  cpz_guestid;
  input  [7:0]  mmu_asid;
  input [31:0]  mmu_dva_m; 
  input         dcc_dvastrobe;  // Data Virtual Address strobe for EJTAG 
  
// Ej Signals  
  input [2:0]   pc_sync_period;       // 3 bits from debug ctl register which 
                                      // specify the sync period
  input         pc_sync_period_diff;  // indicates write to pc sync period 
                                      // used to reset the pc sample counter
  input         new_das_ack_tck;      // tck domain accepts the new dasam_val
  input         dasq;                 // qualifies Data Address Sampling using a data breakpoint
  input         dase;                 // enables data address sampling
  input  [1:0]  brk_d_trig;           // Data triggers
  // Outputs  
  output [55:0] dasam_val; // L/S addr sampled
  output        new_das_gclk;    // gclk domain has a new dasam_val
  output	das_present;

// BEGIN Wire declarations made by MVP
wire pending_sample_da;
wire [55:0] /*[55:0]*/ dasam_trig;
wire [12:0] /*[12:0]*/ counter;
wire dase_deasserted;
wire counter_reset;
wire das_present;
wire [55:0] /*[55:0]*/ sampled_da;
wire sample_en_da;
wire counter_overflow;
wire [55:0] /*[55:0]*/ dasam_reg;
wire dase_reg;
// END Wire declarations made by MVP


  wire		sample_st_send; 
  wire		sample_st_pend;
  wire		sync_wakeup;
   assign das_present = 1'b1;
   // register the W signals
   mvp_cregister_wide #(56) _dasam_reg_55_0_(dasam_reg[55:0],gscanenable, dcc_dvastrobe && dase, gclk, {cpz_guestid[7:0],8'b0,mmu_asid[7:0], mmu_dva_m[31:0]});
   mvp_cregister_wide #(56) _dasam_trig_55_0_(dasam_trig[55:0],gscanenable, brk_d_trig[0] && dase, gclk, dasam_reg[55:0]);
   assign sampled_da[55:0] = dasq ? dasam_trig[55:0] : dasam_reg[55:0];
   mvp_register #(1) _dase_reg(dase_reg, gclk, dase);
   assign dase_deasserted = !dase && dase_reg;

   // counter related logic to detect overflow and increment counter
   // pcse starts/stops the counter, but when its disabled, we take an extra cycle to clear the count
   assign counter_overflow = (counter[12:5] == (8'd1 << pc_sync_period));
   assign counter_reset = greset || counter_overflow ||  dase_deasserted || pc_sync_period_diff;
   mvp_cregister_wide #(13) _counter_12_0_(counter[12:0],gscanenable, dase_reg || greset, gclk,
                                  counter_reset ? 13'd1 : counter[12:0] + 13'd1);

   // When counter fires, set pending_sample until it is sampled
   mvp_cregister #(1) _pending_sample_da(pending_sample_da,greset || counter_overflow  || sample_en_da, gclk,
                              !greset && counter_overflow  && !sample_en_da);

   // Enable sampling only when there is something valid to sample and when we are allowed to change the value
   // NOTE: We *are* allowed to change the sample even if ack is asserted - we just cant transfer to tck until the protocol has completed.
   assign sample_en_da = (pending_sample_da || counter_overflow ) && !sample_st_send;

   m14k_ejt_async_snd #(56,1) dasam_async_snd (
                                              .gscanenable(gscanenable),
                                              .gclk( gclk),
                                              .gfclk( gclk),            // Do not need wakeup logic on gfclk
                                              .reset(greset),
                                              .reset_unsync(1'b0),
                                              .sync_data_in(sampled_da[55:0]),
                                              .sync_sample(sample_en_da),
                                              .sync_sample_st_send(sample_st_send),
                                              .sync_sample_st_pend(sample_st_pend),
                                              .sync_wakeup(sync_wakeup),
                                              .async_data_out(dasam_val),
                                              .async_data_rdy(new_das_gclk),
                                              .async_data_ack(new_das_ack_tck)
                                              );


//verilint 528 off      // Variable set but not used
wire unused_ok;
  assign unused_ok = &{1'b0,
                sync_wakeup,
                sample_st_pend};
//verilint 528 on       // Variable set but not used

  
endmodule


