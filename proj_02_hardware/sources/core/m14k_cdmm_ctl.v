// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//
//      Description: m14k_cdmm_ctl
//      CDMM Memory Proection Unit
//
//      $Id: \$
//      mips_repository_id: m14k_cdmm_ctl.mv, v 3.9 
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

module m14k_cdmm_ctl(
	gclk,
	greset,
	gscanenable,
	cpz_cdmmbase,
	ejt_predonenxt,
	ejt_eadone,
	fdc_present,
	cdmm_mpu_present,
	cdmm_mpu_numregion,
	AHB_EAddr,
	HWRITE,
	biu_if_enable,
	fdc_rdata_nxt,
	cdmm_mpurdata_nxt,
	cpz_gm_m,
	cdmm_rdata_xx,
	cdmm_area,
	cdmm_sel,
	cdmm_hit,
	cdmm_fdc_hit,
	cdmm_fdcread,
	cdmm_fdcgwrite,
	cdmm_mpu_hit,
	cdmm_mpuread,
	cdmm_mpugwrite);

	input	gclk;
	input	greset;
	input	gscanenable;
	input [31:15]	cpz_cdmmbase;
	input	ejt_predonenxt;
	input	ejt_eadone;
	input	fdc_present;
	input	cdmm_mpu_present;
	input [3:0]	cdmm_mpu_numregion;
	input [31:2]	AHB_EAddr;
	input	HWRITE;
	input	biu_if_enable;
	input  [31:0]	fdc_rdata_nxt; //fdc read data
	input  [31:0]	cdmm_mpurdata_nxt; //mpu read data
	input	cpz_gm_m;
	output [31:0]	cdmm_rdata_xx; // CDMM read data
	output	cdmm_area;
	output	cdmm_sel;
	output	cdmm_hit;
	output	cdmm_fdc_hit;
	output 	cdmm_fdcread;
	output	cdmm_fdcgwrite;
	output	cdmm_mpu_hit;
	output 	cdmm_mpuread;
	output	cdmm_mpugwrite;

// BEGIN Wire declarations made by MVP
wire cdmm_sel;
wire cdmm_mpuread;
wire cdmm_area_fdc;
wire cdmm_fdcread;
wire mpu_hit_nfdc_tmp;
wire cdmm_fdcgwrite;
wire cdmm_mpu_hit;
wire cdmm_fdc_hit;
wire cdmm_area;
wire last_read;
wire mpu_hit_tmp;
wire cdmm_mpugwrite;
wire cdmm_arearead;
wire cdmm_area_mpu;
wire [31:0] /*[31:0]*/ cdmm_rdata_nxt;
wire [31:0] /*[31:0]*/ cdmm_rdata_xx;
wire cdmm_hit;
wire mpu_hit_fdc_tmp;
// END Wire declarations made by MVP



assign cdmm_area = (AHB_EAddr[31:15] == cpz_cdmmbase[31:15]);
assign cdmm_hit = cdmm_area && (fdc_present && !cpz_gm_m || cdmm_mpu_present);
mvp_register #(1) _cdmm_sel(cdmm_sel, gclk, cdmm_hit);

// Area / Device Hit Controls
// Area hits if device is implemented and cdmm matches
// Device hits if area hits and specific DRB address is correct
// Selects are registered versions of the hits
assign cdmm_area_fdc = cdmm_area && fdc_present && !cpz_gm_m;
assign cdmm_fdc_hit = cdmm_area_fdc & (AHB_EAddr[14:8] == 7'b0) & (AHB_EAddr[7:6] != 2'b11);
//cdmm_fdc_sel = register( gclk, cdmm_fdc_hit);

assign cdmm_area_mpu = cdmm_area && cdmm_mpu_present;

assign mpu_hit_nfdc_tmp  = 
		cdmm_mpu_numregion[3:1]==3'o0 ? AHB_EAddr[9:6]==4'h0 :
		cdmm_mpu_numregion[3:1]==3'o1 ? AHB_EAddr[9:7]==3'h0 :
		cdmm_mpu_numregion[3:1]==3'o2 ? AHB_EAddr[9:7]==3'h0 | AHB_EAddr[9:6]==4'h2 :
		cdmm_mpu_numregion[3:1]==3'o3 ? AHB_EAddr[9:8]==2'b00 :
		cdmm_mpu_numregion[3:1]==3'o4 ? AHB_EAddr[9:8]==2'b00 | AHB_EAddr[9:6]==4'h4 :
		cdmm_mpu_numregion[3:1]==3'o5 ? AHB_EAddr[9:8]==2'b00 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 :
		cdmm_mpu_numregion[3:1]==3'o6 ? AHB_EAddr[9:8]==2'b00 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 | AHB_EAddr[9:6]==4'h6 :
						AHB_EAddr[9]==1'b0 ;
assign mpu_hit_fdc_tmp = cdmm_mpu_numregion[3:1]==3'o0 ? AHB_EAddr[9:6]==4'h3 :
                   cdmm_mpu_numregion[3:1]==3'o1 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 :
                   cdmm_mpu_numregion[3:1]==3'o2 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 :
                   cdmm_mpu_numregion[3:1]==3'o3 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 | AHB_EAddr[9:6]==4'h6 :
                   cdmm_mpu_numregion[3:1]==3'o4 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 | 
						   AHB_EAddr[9:6]==4'h6 | AHB_EAddr[9:6]==4'h7 :
                   cdmm_mpu_numregion[3:1]==3'o5 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 |
						   AHB_EAddr[9:6]==4'h6 | AHB_EAddr[9:6]==4'h7 | AHB_EAddr[9:6]==4'h8 :
                   cdmm_mpu_numregion[3:1]==3'o6 ? AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 |
						   AHB_EAddr[9:6]==4'h6 | AHB_EAddr[9:6]==4'h7 | AHB_EAddr[9:6]==4'h8 |
						   AHB_EAddr[9:6]==4'h9 :
                   				   AHB_EAddr[9:6]==4'h3 | AHB_EAddr[9:6]==4'h4 | AHB_EAddr[9:6]==4'h5 | 
						   AHB_EAddr[9:6]==4'h6 | AHB_EAddr[9:6]==4'h7 | AHB_EAddr[9:6]==4'h8 |
						   AHB_EAddr[9:6]==4'h9 | AHB_EAddr[9:6]==4'ha ;
assign mpu_hit_tmp = fdc_present & mpu_hit_fdc_tmp | ~fdc_present & mpu_hit_nfdc_tmp;
assign cdmm_mpu_hit = cdmm_area_mpu & AHB_EAddr[14:10]==5'b0 & mpu_hit_tmp;
//cdmm_mpu_sel = register( gclk, cdmm_mpu_hit);


// Read / Write Controls
/* fdc controls are under tap because they are tightly coupled with tap serial streams
*/
//CDMM AREA
assign cdmm_arearead = !HWRITE & ejt_predonenxt & cdmm_area;
//cdmm_areagwrite = HWRITE & ejt_eadone & biu_if_enable & cdmm_area;

// CDMM FDC
assign cdmm_fdcread = !HWRITE & ejt_predonenxt & cdmm_fdc_hit;
assign cdmm_fdcgwrite = HWRITE & ejt_eadone & biu_if_enable & cdmm_fdc_hit;
// CDMM MPU
assign cdmm_mpuread	= !HWRITE & ejt_predonenxt & cdmm_mpu_hit;
assign cdmm_mpugwrite	=  HWRITE & ejt_eadone & biu_if_enable & cdmm_mpu_hit;


// Read Mux 
mvp_mux2 #(32) _cdmm_rdata_nxt_31_0_(cdmm_rdata_nxt[31:0],cdmm_fdc_hit, cdmm_mpurdata_nxt, fdc_rdata_nxt);
mvp_register #(1) _last_read(last_read, gclk, cdmm_fdcread | cdmm_mpuread);
mvp_cregister_wide #(32) _cdmm_rdata_xx_31_0_(cdmm_rdata_xx[31:0],gscanenable,  
				( cdmm_arearead & ~last_read), 
				gclk,
				cdmm_rdata_nxt);

endmodule

