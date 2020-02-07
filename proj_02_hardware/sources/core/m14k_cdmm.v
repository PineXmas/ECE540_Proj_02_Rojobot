// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//	Description: m14k_cdmm
//
//      $Id: \$
//      mips_repository_id: m14k_cdmm.hook, v 3.14 
//
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

module m14k_cdmm(
	gclk,
	greset,
	gscanenable,
	AHB_EAddr,
	HWRITE,
	biu_if_enable,
	ejt_predonenxt,
	ejt_eadone,
	fdc_present,
	fdc_rdata_nxt,
	cdmm_wdata_xx,
	mmu_cdmm_kuc_m,
	mmu_ivastrobe,
	mpc_newiaddr,
	cpz_cdmmbase,
	cpz_vz,
	cpz_hotdm_i,
	cpz_dm_m,
	cpz_kuc_i,
	cpz_kuc_m,
	cpz_iret_ret,
	cpz_eret_m,
	mpc_squash_i,
	mpc_pexc_i,
	mpc_pexc_e,
	mpc_atomic_m,
	mpc_busty_m,
	mpc_mpustrobe_w,
	mpc_mputake_w,
	mpc_cleard_strobe,
	mpc_run_ie,
	mpc_run_m,
	mpc_fixup_m,
	mpc_ebld_e,
	mpc_ebexc_w,
	mpc_isamode_i,
	mpc_mputriggeredres_i,
	mpc_macro_e,
	mpc_macro_end_e,
	icc_macroend_e,
	icc_macro_e,
	icc_slip_n_nhalf,
	icc_umipsfifo_stat,
	dcc_dvastrobe,
	mpc_icop_m,
	dcc_dcopaccess_m,
	edp_cacheiva_i,
	edp_iva_i,
	mmu_dva_m,
	cpz_gm_m,
	cdmm_area,
	cdmm_sel,
	cdmm_hit,
	cdmm_fdc_hit,
	cdmm_fdcread,
	cdmm_fdcgwrite,
	cdmm_mpu_present,
	cdmm_mmulock,
	cdmm_mpu_numregion,
	cdmm_mputriggered_i,
	cdmm_mputriggered_m,
	cdmm_mpuipdt_w,
	cdmm_ej_override,
	cdmm_mputrigresraw_i,
	cdmm_rdata_xx);

/*hookios*//* IO declarations added by hookup */
/* End of hookup IO declarations */
/* Wire declarations added by hookup */
wire cdmm_mpu_hit;
wire cdmm_mpugwrite;
wire [31:0] cdmm_mpurdata_nxt;		//mpu read data
wire cdmm_mpuread;
/* End of hookup wire declarations */

	input	gclk;
	input	greset;
	input	gscanenable;

	input [31:2]	AHB_EAddr;
	input	HWRITE;
	input	biu_if_enable;
	input	ejt_predonenxt;
	input	ejt_eadone;

	input	fdc_present;
	input  [31:0]	fdc_rdata_nxt; //fdc read data
	input [31:0]	cdmm_wdata_xx;
	
	input	mmu_cdmm_kuc_m;
	input	mmu_ivastrobe;
	input	mpc_newiaddr;
	input [31:15]	cpz_cdmmbase;
	input	cpz_vz;
	input	cpz_hotdm_i;
	input	cpz_dm_m;
	input	cpz_kuc_i;
	input	cpz_kuc_m;
	input	cpz_iret_ret;		//active iret for writing registers
	input	cpz_eret_m;		//active eret for writing registers (m stage)
	input	mpc_squash_i;
	input	mpc_pexc_i;
	input	mpc_pexc_e;
	input	mpc_atomic_m;
	input [2:0]	mpc_busty_m;
	input	mpc_mpustrobe_w;
	input	mpc_mputake_w;
	input	mpc_cleard_strobe;
	input	mpc_run_ie;
	input	mpc_run_m;
	input	mpc_fixup_m;
	input	mpc_ebld_e;	// ebase write in e stage
	input	mpc_ebexc_w;	    // core taking ebase exception
	input	mpc_isamode_i;
	input	mpc_mputriggeredres_i;
	input	mpc_macro_e;
	input	mpc_macro_end_e;
	input	icc_macroend_e;
	input	icc_macro_e;
	input	icc_slip_n_nhalf;
	input [3:0]	icc_umipsfifo_stat;
	input	dcc_dvastrobe;
	input	mpc_icop_m;
	input	dcc_dcopaccess_m;
	input [31:0]	edp_cacheiva_i;
	input [31:0]	edp_iva_i;
	input [31:0]	mmu_dva_m;
	input	cpz_gm_m;

	output	cdmm_area;
	output	cdmm_sel;
	output	cdmm_hit;
	output	cdmm_fdc_hit;
	output 	cdmm_fdcread;
	output	cdmm_fdcgwrite;
	output	cdmm_mpu_present;
	output	cdmm_mmulock;
	output [3:0] cdmm_mpu_numregion;
	output	cdmm_mputriggered_i;
	output	cdmm_mputriggered_m;
	output	cdmm_mpuipdt_w;
	output	cdmm_ej_override;
	output	cdmm_mputrigresraw_i;
	output [31:0]	cdmm_rdata_xx; // CDMM read data


/*hookup*/
m14k_cdmm_ctl cdmm_ctl (
	.AHB_EAddr(AHB_EAddr),
	.HWRITE(HWRITE),
	.biu_if_enable(biu_if_enable),
	.cdmm_area(cdmm_area),
	.cdmm_fdc_hit(cdmm_fdc_hit),
	.cdmm_fdcgwrite(cdmm_fdcgwrite),
	.cdmm_fdcread(cdmm_fdcread),
	.cdmm_hit(cdmm_hit),
	.cdmm_mpu_hit(cdmm_mpu_hit),
	.cdmm_mpu_numregion(cdmm_mpu_numregion),
	.cdmm_mpu_present(cdmm_mpu_present),
	.cdmm_mpugwrite(cdmm_mpugwrite),
	.cdmm_mpurdata_nxt(cdmm_mpurdata_nxt),
	.cdmm_mpuread(cdmm_mpuread),
	.cdmm_rdata_xx(cdmm_rdata_xx),
	.cdmm_sel(cdmm_sel),
	.cpz_cdmmbase(cpz_cdmmbase),
	.cpz_gm_m(cpz_gm_m),
	.ejt_eadone(ejt_eadone),
	.ejt_predonenxt(ejt_predonenxt),
	.fdc_present(fdc_present),
	.fdc_rdata_nxt(fdc_rdata_nxt),
	.gclk(gclk),
	.greset(greset),
	.gscanenable(gscanenable));

/*hookup*/
`M14K_MPU_MODULE cdmm_mpu (
	.AHB_EAddr(AHB_EAddr[14:2]),
	.cdmm_ej_override(cdmm_ej_override),
	.cdmm_mmulock(cdmm_mmulock),
	.cdmm_mpu_hit(cdmm_mpu_hit),
	.cdmm_mpu_numregion(cdmm_mpu_numregion),
	.cdmm_mpu_present(cdmm_mpu_present),
	.cdmm_mpugwrite(cdmm_mpugwrite),
	.cdmm_mpuipdt_w(cdmm_mpuipdt_w),
	.cdmm_mpurdata_nxt(cdmm_mpurdata_nxt),
	.cdmm_mpuread(cdmm_mpuread),
	.cdmm_mputriggered_i(cdmm_mputriggered_i),
	.cdmm_mputriggered_m(cdmm_mputriggered_m),
	.cdmm_mputrigresraw_i(cdmm_mputrigresraw_i),
	.cdmm_wdata_xx(cdmm_wdata_xx),
	.cpz_dm_m(cpz_dm_m),
	.cpz_eret_m(cpz_eret_m),
	.cpz_hotdm_i(cpz_hotdm_i),
	.cpz_iret_ret(cpz_iret_ret),
	.cpz_kuc_i(cpz_kuc_i),
	.cpz_kuc_m(cpz_kuc_m),
	.cpz_vz(cpz_vz),
	.dcc_dcopaccess_m(dcc_dcopaccess_m),
	.dcc_dvastrobe(dcc_dvastrobe),
	.edp_cacheiva_i(edp_cacheiva_i),
	.edp_iva_i(edp_iva_i),
	.fdc_present(fdc_present),
	.gclk(gclk),
	.greset(greset),
	.gscanenable(gscanenable),
	.icc_macro_e(icc_macro_e),
	.icc_macroend_e(icc_macroend_e),
	.icc_slip_n_nhalf(icc_slip_n_nhalf),
	.icc_umipsfifo_stat(icc_umipsfifo_stat),
	.mmu_cdmm_kuc_m(mmu_cdmm_kuc_m),
	.mmu_dva_m(mmu_dva_m),
	.mmu_ivastrobe(mmu_ivastrobe),
	.mpc_atomic_m(mpc_atomic_m),
	.mpc_busty_m(mpc_busty_m),
	.mpc_cleard_strobe(mpc_cleard_strobe),
	.mpc_ebexc_w(mpc_ebexc_w),
	.mpc_ebld_e(mpc_ebld_e),
	.mpc_fixup_m(mpc_fixup_m),
	.mpc_icop_m(mpc_icop_m),
	.mpc_isamode_i(mpc_isamode_i),
	.mpc_macro_e(mpc_macro_e),
	.mpc_macro_end_e(mpc_macro_end_e),
	.mpc_mpustrobe_w(mpc_mpustrobe_w),
	.mpc_mputake_w(mpc_mputake_w),
	.mpc_mputriggeredres_i(mpc_mputriggeredres_i),
	.mpc_newiaddr(mpc_newiaddr),
	.mpc_pexc_e(mpc_pexc_e),
	.mpc_pexc_i(mpc_pexc_i),
	.mpc_run_ie(mpc_run_ie),
	.mpc_run_m(mpc_run_m),
	.mpc_squash_i(mpc_squash_i));

endmodule	// m14k_cpu
