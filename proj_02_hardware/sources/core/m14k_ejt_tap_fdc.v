// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//
//      Description: m14k_ejt_tap_fdc
//      EJTAG TAP FDC module
//
//      $Id: \$
//      mips_repository_id: m14k_ejt_tap_fdc.mv, v 1.4 
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


module m14k_ejt_tap_fdc(
	gclk,
	gfclk,
	greset,
	gscanenable,
	cdmm_fdcread,
	cdmm_fdcgwrite,
	cdmm_fdc_hit,
	mmu_cdmm_kuc_m,
	AHB_EAddr,
	cdmm_wdata_xx,
	cpz_kuc_m,
	fdc_rdata_nxt,
	fdc_present,
	fdc_rxdata_tck,
	fdc_rxdata_rdy_tck,
	fdc_rxdata_ack_gclk,
	fdc_txdata_gclk,
	fdc_txdata_rdy_gclk,
	fdc_txdata_ack_tck,
	fdc_txtck_used_tck,
	fdc_rxint_tck,
	fdc_rxint_ack_gclk,
	ej_fdc_int,
	fdc_busy_xx);


   input         gclk;
   input         gfclk;
   input 	 greset;         // reset
   input         gscanenable;         

     input 	cdmm_fdcread;
     input	cdmm_fdcgwrite;
     input	cdmm_fdc_hit;
     input 	mmu_cdmm_kuc_m;
     input   [14:2]  AHB_EAddr;
     input [31:0] cdmm_wdata_xx;      
     input       cpz_kuc_m;
   output [31:0] fdc_rdata_nxt; // CDMM read data
   output	fdc_present;
   
   // Async signals to/from TCK module
   input [35:0]  fdc_rxdata_tck;       // Data value
   input 	 fdc_rxdata_rdy_tck;   // Data is ready
   output 	 fdc_rxdata_ack_gclk;  // Data has been accepted

   output [35:0] fdc_txdata_gclk;      // Data value
   output 	 fdc_txdata_rdy_gclk;  // Data is ready
   input 	 fdc_txdata_ack_tck;   // Data has been accepted

   input 	 fdc_txtck_used_tck;   // Tx TCK buffer occupied
   input 	 fdc_rxint_tck;        // FDC Interrupt Request
   output 	 fdc_rxint_ack_gclk;   // Int. Req. seen

   output 	 ej_fdc_int;       // Fast Debug Channel Interrupt
   output 	 fdc_busy_xx;          // Wakeup to transfer fast debug channel data

// BEGIN Wire declarations made by MVP
wire [1:0] /*[1:0]*/ fdc_txthresh;
wire fdc_rxint_ack_gclk_1;
wire [7:0] /*[7:0]*/ fdc_rxsize;
wire fdc_uw;
wire [31:0] /*[31:0]*/ fdc_acsr;
wire fdc_rxempty;
wire tx_array_push;
wire [7:0] /*[7:0]*/ fdc_rxcount;
wire rx_array_push;
wire fdc_rxint_ack_reg;
wire [7:0] /*[7:0]*/ fdc_txsize;
wire [35:0] /*[35:0]*/ tx_data_in;
wire fdc_tx_hit;
wire ej_fdc_int;
wire fdc_txfull;
wire fdc_acsr_hit;
wire fdc_read_lgl;
wire fdc_txalmostempty;
wire [1:0] /*[1:0]*/ fdc_rxthresh;
wire tx_gclk_buffer_used;
wire [7:0] /*[7:0]*/ fdc_txcount;
wire fdc_ur;
wire fdc_stat_read;
wire fdc_device_hit;
wire [31:0] /*[31:0]*/ fdc_stat;
wire tx_int;
wire probe_int;
wire [31:0] /*[31:0]*/ fdc_cfg;
wire mmu_fdc_kuc_m;
wire last_read;
wire rx_int;
wire fdc_reserved;
wire fdc_rx_read;
wire fdc_rx_hit;
wire fdc_sw;
wire fdc_rxalmostfull;
wire fdc_busy_xx;
wire probe_int_assert;
wire tx_array_pop;
wire fdc_write_lgl;
wire fdc_acsr_lgl;
wire fdc_acsr_read;
wire [31:0] /*[31:0]*/ fdc_rdata_nxt;
wire fdc_rxfull;
wire fdc_cfg_read;
wire fdc_stat_hit;
wire fdc_rxint_ack_gclk;
wire [4:0] /*[4:0]*/ fdc_txchan;
wire tx_if_sample;
wire fdc_tx_write;
wire fdc_acsr_write;
wire rx_if_enable;
wire fdc_present;
wire fdc_cfg_hit;
wire fdc_cfg_write;
wire fdc_txempty;
wire fdc_rxint_ack_gclk_2;
wire fdc_sr;
wire rx_array_pop;
// END Wire declarations made by MVP

   

   
   // _array terms for the local array of FIFO cells
   // _if terms for things coming from the handshake logic
   wire 	 rx_array_full, rx_array_empty, tx_array_full, tx_array_empty;
   wire 	 rx_if_data_vld, rx_if_data_pnd;
   wire 	 tx_if_wakeup, rx_if_wakeup;
   wire 	 tx_if_state_send, tx_if_state_pend;
   wire 	 fdc_txtck_used;

   wire [3:0] 	 fdc_rxchan;
   wire [31:0] 	 fdc_rxdata;
   wire [35:0] 	 rx_if_data, rx_data_out, tx_data_out;
   

   wire [`M14K_FIFO_DEPTH_WIDTH-1:0] rx_array_depth, tx_array_depth;
   
   assign fdc_present = 1'b1;
   
   // CDMM - Common Device Memory Map
   //      FDC is currently the only device supported and handles all CDMM
   //      accesses in lower 4KB (upper 28KB handled by AREA module).
   // Device 0:  Fast Debug Channel
   //            0x00: Device Access Control Register
   //            0x08: FDC Config
   //            0x10: FDC Status
   //            0x18: FDC RxFIFO
   //            0x20 + 0x8*n: FDC TxFIFOn
   //            0xa0-0xbf: reserved

   assign fdc_device_hit = cdmm_fdc_hit;
   assign mmu_fdc_kuc_m = mmu_cdmm_kuc_m;

   // Determine if this is a legal access
   assign fdc_acsr_lgl =  (mmu_fdc_kuc_m==1'b0);
   assign fdc_read_lgl =  (mmu_fdc_kuc_m==1'b0) |
		   (mmu_fdc_kuc_m & fdc_ur);
   assign fdc_write_lgl = (mmu_fdc_kuc_m==1'b0) |
		   (mmu_fdc_kuc_m & fdc_uw);   
   
   // Register decoding   
   assign fdc_reserved   = (AHB_EAddr[7:5] == 3'b101);

   assign fdc_acsr_hit = fdc_device_hit & (AHB_EAddr[7:3] == 5'h0);
   assign fdc_cfg_hit  = fdc_device_hit & (AHB_EAddr[7:3] == 5'h1);
   assign fdc_stat_hit = fdc_device_hit & (AHB_EAddr[7:3] == 5'h2);
   assign fdc_rx_hit   = fdc_device_hit & (AHB_EAddr[7:3] == 5'h3);
   assign fdc_tx_hit   = fdc_device_hit & (|(AHB_EAddr[7:5])) & ~fdc_reserved;

   // Write Strobes
   assign fdc_acsr_write = fdc_acsr_lgl  & fdc_acsr_hit & cdmm_fdcgwrite;
   assign fdc_cfg_write  = fdc_write_lgl & fdc_cfg_hit  & cdmm_fdcgwrite;
   assign fdc_tx_write   = fdc_write_lgl & fdc_tx_hit   & cdmm_fdcgwrite;
   // No writeable bits in status or rx registers
   
   // Read strobe
   // Read request shows up on bus for 2 consecutive cycles
   // Need to turn this into single read request to avoid
   // popping two entries from RxFIFO
   mvp_register #(1) _last_read(last_read, gclk, cdmm_fdcread);
   
   assign fdc_acsr_read  = fdc_acsr_lgl & fdc_acsr_hit & cdmm_fdcread;
   assign fdc_cfg_read   = fdc_read_lgl & fdc_cfg_hit  & cdmm_fdcread;
   assign fdc_stat_read  = fdc_read_lgl & fdc_stat_hit & cdmm_fdcread;
   assign fdc_rx_read    = fdc_read_lgl & fdc_rx_hit & cdmm_fdcread & ~last_read;

   // Return 0 for TxFIFO, FDC Reserved, and all other CDMM addresses
   // as well as unauthorized access
   // Registered for timing reasons
   mvp_mux1hot_4 #(32) _fdc_rdata_nxt_31_0_(fdc_rdata_nxt[31:0],fdc_acsr_read, fdc_acsr,
				 fdc_cfg_read,  fdc_cfg,
				 fdc_stat_read, fdc_stat,
				 fdc_rx_read,   fdc_rxdata);

   // FDCACSR
   assign fdc_acsr[31:0] = {8'hfd,       // Device Type:     FDC
		     3'h0,        // Unused
		     5'h2,        // Device Size:     0x2 (192B)
		     4'h0,        // Device Revision: 0x0
		     8'h0,        // Unused
		     fdc_uw,      // User Writable
		     fdc_ur,      // User Readable
		     fdc_sw,      // Supervisor Writable
		     fdc_sr};     // Supervisor Readable

   mvp_cregister_wide #(4) _fdc_uw_fdc_ur_fdc_sw_fdc_sr({fdc_uw,
    fdc_ur,
    fdc_sw,
    fdc_sr}, gscanenable, fdc_acsr_write | greset,
			     gclk, {4{~greset}} & cdmm_wdata_xx[3:0]);

   // FDC Config Register
   assign fdc_cfg[31:0] = {12'h0,          // Unused
		    fdc_txthresh,   // TxIntThreshold
		    fdc_rxthresh,   // RxIntThreshold
		    fdc_txsize,     // Number of Tx entries
		    fdc_rxsize};    // Number of Rx entries

   // Interrupt threshholds:
   //   Tx: 0 - Disabled, 1 - Empty, 2 - !Full,  3 - Almost Empty
   //   Rx: 0 - Disabled, 1 - Full,  2 - !Empty, 3 - Almost Full
   mvp_cregister_wide #(4) _fdc_txthresh_1_0({fdc_txthresh[1:0],
    fdc_rxthresh[1:0]}, gscanenable, fdc_cfg_write | greset,
					gclk, {4{~greset}} & cdmm_wdata_xx[19:16]);

   // Two registers in handshake logic are used as active
   // FIFO entries and are included in size
   assign fdc_txsize[7:0] = tx_array_depth + 8'h2;
   assign fdc_rxsize[7:0] = rx_array_depth + 8'h2;

   // FDC Status Register
   assign fdc_stat[31:0] = {fdc_txcount,  // Num Tx entries used
		     fdc_rxcount,  // Num Rx entries used
		     8'h0,         // Unused
		     fdc_rxchan,   // Channel # for top RxFIFO
		     fdc_rxempty,  // RxFIFO Empty
		     fdc_rxfull,   // RxFIFO Full
		     fdc_txempty,  // TxFIFO Empty
		     fdc_txfull};  // TxFIFO Full

   // Count fields are optional - not implemented
   assign fdc_txcount[7:0] = 8'b0;
   assign fdc_rxcount[7:0] = 8'b0;
   

   // FIFO Status
   //    Overall FIFOs include 2 flops that are part of the asynch
   //    transfer logic.  However, since these entries are not directly
   //    accessible, do not want to tell software that there is space(tx)
   //    or data(rx) available and have it not be true.
   //    Include +1 entry ( gclk side of asynch x-fer) for all since data will 
   //    flow to/from there in one cycle, before software could see other state
   //    Include +2 entry (tck side) in txempty to allow software to determine
   //    if all data has been taken and to allow optimal interrupts.
   //    Include +2 entry in rxfull for symmetry & optimal interrupts
   //    tx_almostempty/rx_almostfull used for interrupt and consider N+1
   
   //    Note: For minimal area, main FIFO is 0-size.  Full and Empty (from FIFO)
   //    will both be asserted.
   //  

   // Indication that TCK Tx buffer is in use since it is not
   // directly inferable from handshake signals.  Only use this
   // version for status though 
   m14k_ejt_tripsync fdc_txtck_used_(.q(fdc_txtck_used),
					     .d(fdc_txtck_used_tck),
					     .gclk( gclk));

   assign fdc_rxfull = rx_array_full & rx_if_data_vld & rx_if_data_pnd;
   assign fdc_rxempty = rx_array_empty & ~rx_if_data_vld;

   assign fdc_rxalmostfull = rx_array_full & rx_if_data_vld;

   // Averted corner case here: Should not read the
   // empty flag or signal int until fully empty
   // 
   // When last piece of data is transferred to TCK, 
   // fdc_txtck_used_tck -> 1 in same TCK as fdc_txdata_ack_tck -> 1
   // These are separately synchronized though and we may not
   // see the same value, but will be off by at most 1 gclk cycle.
   // This cycle is covered by the additional cycle between
   // the synchronized ack->1 and tx_gclk_buffer_used(fdc_txdata_rdy_gclk)-> 0
   // If txtck_used is earlier, terms 2&3 will overlap for 2 cycles
   // At same time, terms 2&3 will overlap for 1 cycle
   // If txtck_used is later, there is no overlap, but no gap either
   assign tx_gclk_buffer_used = tx_if_state_pend | tx_if_state_send;

   assign fdc_txempty = tx_array_empty & ~tx_gclk_buffer_used & ~fdc_txtck_used;
   assign fdc_txfull = tx_array_full & fdc_txdata_rdy_gclk;

   // AlmostEmpty - all gclk buffers are empty.  0 or 1 entry in TCK buffer
   // Note: if TCK is not running, we can have 1 gclk entry and not
   // report AlmostEmpty
   assign fdc_txalmostempty = tx_array_empty & ~tx_gclk_buffer_used;
   
   // FDC RXFIFO
   `M14K_FDC_RXFIFO #(36) rxfifo_ (
				       .data_out(rx_data_out),
				       .fifo_full(rx_array_full),
				       .fifo_empty(rx_array_empty),
				       .fifo_depth(rx_array_depth),
				       .fifo_pop(rx_array_pop),
				       .fifo_push(rx_array_push),
				       .data_in(rx_if_data),
				       .gscanenable(gscanenable),
				       .gclk( gclk),
				       .greset(greset)
				       );

   assign {fdc_rxchan[3:0], fdc_rxdata[31:0]} = rx_data_out[35:0];
    

   // Arch. undefined if reading an empty rxfifo
   //   Skip the pop to avoid causing fifo problems
   //   Data value will be previous data
   assign rx_array_pop = fdc_rx_read & ~rx_array_empty;

   // Push if data valid and space is or will be available
   assign rx_array_push = rx_if_data_vld & (~rx_array_full | fdc_rx_read);
   
   // Enable for i/f receive flops
   // (enabling on read is overkill if array is present, but needed for stub array)
   assign rx_if_enable = ~rx_if_data_vld |   // flops are empty
		  ~rx_array_full |    // If there is space available
		  fdc_rx_read |       // or will be from a read
		  greset;             // clear out receive flops at reset

   m14k_ejt_async_rec #(36,1) rxfifo_async_rec (
					       .gscanenable(gscanenable),
					       .gclk( gclk),
					       .gfclk( gfclk),
					       .reset(greset),
					       .reset_unsync(1'b0),
					       .sync_data_enable(rx_if_enable),
					       .sync_data_out(rx_if_data),
					       .sync_data_vld(rx_if_data_vld),
					       .sync_data_pnd(rx_if_data_pnd),
					       .sync_wakeup(rx_if_wakeup),
					       .async_data_in(fdc_rxdata_tck),
					       .async_data_rdy(fdc_rxdata_rdy_tck),
					       .async_data_ack(fdc_rxdata_ack_gclk)
					       );
   

   // TxFIFO
   `M14K_FDC_TXFIFO #(36) txfifo_ (
				       .data_out(tx_data_out),
				       .fifo_full(tx_array_full),
				       .fifo_empty(tx_array_empty),
				       .fifo_depth(tx_array_depth),
				       .fifo_pop(tx_array_pop),
				       .fifo_push(tx_array_push),
				       .data_in(tx_data_in),
				       .gscanenable(gscanenable),
				       .gclk( gclk),
				       .greset(greset)
				       );

   // TxChannel -> channel number is implicit in the address
   // used to write the fifo.  All of the addresses will write
   // the data value and channel number to the TxFIFO
   //  5b expression, but only 4b needed for valid addresses
   assign fdc_txchan[4:0] = (AHB_EAddr[7:3] - 5'h4);

   // Data packet includes channel ID and 32b data value   
   assign tx_data_in[35:0] = {fdc_txchan[3:0], cdmm_wdata_xx[31:0]};
				       
   // Arch. undefined to write if FIFO is full
   //  We will drop write in this case
   assign tx_array_push = ~tx_array_full & fdc_tx_write;

   // Indicate that there is data available. Disable in PEND state to 
   // avoid overwriting previous data.  Disabling in SEND is redundant
   // with logic in _snd module, but is needed for popping local FIFO
   assign tx_array_pop = ~tx_array_empty & ~tx_gclk_buffer_used;

   // Tx I/F sample
   assign tx_if_sample = (~tx_array_empty & ~tx_if_state_pend) | 
		  (fdc_tx_write & tx_array_full & tx_array_empty); 
   

   m14k_ejt_async_snd #(36,1) txfifo_async_snd (
					       .gscanenable(gscanenable),
					       .gclk( gclk),
					       .gfclk( gfclk),
					       .reset(greset),
					       .reset_unsync(1'b0),
					       .sync_data_in(tx_data_out),
					       .sync_sample(tx_if_sample),
					       .sync_sample_st_send(tx_if_state_send),
					       .sync_sample_st_pend(tx_if_state_pend),
					       .sync_wakeup(tx_if_wakeup),
					       .async_data_out(fdc_txdata_gclk),
					       .async_data_rdy(fdc_txdata_rdy_gclk),
					       .async_data_ack(fdc_txdata_ack_tck)
					       );
   // Interrupt generation
   // Rx/Tx can be generated based on queue occupancy or 
   // Rx can be explicitly requested by probe

   // Rx Interupt
   mvp_mux4 #(1) _rx_int(rx_int,fdc_rxthresh,
		 1'b0, 
		 fdc_rxfull,                 
		 ~fdc_rxempty,
		 fdc_rxalmostfull);
   
   // Tx Interupt
   mvp_mux4 #(1) _tx_int(tx_int,fdc_txthresh,
		 1'b0,
		 fdc_txempty,
		 !fdc_txfull,
		 fdc_txalmostempty);
 
   // synchronize RxInt request from probe
   //   Send back to TCK to clear the interrupt there
   mvp_cregister #(1) _fdc_rxint_ack_gclk_1(fdc_rxint_ack_gclk_1,fdc_rxint_tck|greset, gfclk, fdc_rxint_tck & ~greset);
   mvp_register #(1) _fdc_rxint_ack_gclk_2(fdc_rxint_ack_gclk_2, gfclk, fdc_rxint_ack_gclk_1);
   mvp_register #(1) _fdc_rxint_ack_gclk(fdc_rxint_ack_gclk, gfclk, fdc_rxint_ack_gclk_2);

   // Detect posedge of probe interrupt signal 
   mvp_register #(1) _fdc_rxint_ack_reg(fdc_rxint_ack_reg, gfclk, fdc_rxint_ack_gclk);

   assign probe_int_assert = fdc_rxint_ack_gclk & ~fdc_rxint_ack_reg;
   
   // Probe Interrupt only enabled when RxInts are enabled. 
   // Set when above is seen and cleared once the RxFIFO has been drained
   mvp_register #(1) _probe_int(probe_int, gfclk, (|(fdc_rxthresh)) & 
			        (probe_int_assert |
				 (probe_int & ~fdc_rxempty)) & ~greset);

   assign ej_fdc_int = probe_int | rx_int | tx_int;
   

   // Wakeup logic: this logic is purely to wake the core up enough
   // to move the data across the tck/gclk i/f.  Rely on interrupt
   // signalling to keep the core awake to do anything further
   //					   
   // Request starting of gclk to send or receive data
   // Rx: data can be moved from receive flop to array
   // Rx: i/f requests wakeup to advance data or complete handshake
   // Tx: i/f requests wakeup to advance data or complete handshake
   mvp_register #(1) _fdc_busy_xx(fdc_busy_xx, gfclk, (~rx_array_full & rx_if_data_vld) |
			         rx_if_wakeup | tx_if_wakeup);

   
//verilint 528 off      // Variable set but not used
wire unused_ok;
  assign unused_ok = &{1'b0,
		fdc_txchan[4]
                };
//verilint 528 on       // Variable set but not used
                
   
   
endmodule



  










