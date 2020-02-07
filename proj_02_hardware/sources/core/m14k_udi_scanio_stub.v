// mvp Version 2.24
// cmd line +define: MIPS_SIMULATION
// cmd line +define: MIPS_VMC_DUAL_INST
// cmd line +define: MIPS_VMC_INST
// cmd line +define: M14K_NO_ERROR_GEN
// cmd line +define: M14K_NO_SHADOW_CACHE_CHECK
// cmd line +define: M14K_TRACER_NO_FDCTRACE
//
// Description:  m14k_scanio_stub
//      Stub module for I/Os where scan flops could be inserted
//
// $Id: \$
// mips_repository_id: m14k_udi_scanio_stub.mv, v 1.2 
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

//verilint 240 off  // Unused input
`include "m14k_const.vh"
module m14k_udi_scanio_stub(
	gclk,
	gscanenable,
	gscanmode,
	UDI_rd_m,
	UDI_wrreg_e,
	UDI_ri_e,
	UDI_stall_m,
	UDI_present,
	UDI_honor_cee,
	UDI_irvalid_e,
	UDI_rs_e,
	UDI_rt_e,
	UDI_endianb_e,
	UDI_kill_m,
	UDI_start_e,
	UDI_run_m,
	UDI_rd_buf_m,
	UDI_wrreg_buf_e,
	UDI_ri_buf_e,
	UDI_stall_buf_m,
	UDI_present_buf,
	UDI_honor_cee_buf);


    input               gclk;
    input               gscanenable;
    input               gscanmode;
    input [31:0]        UDI_rd_m;    
    input [4:0]         UDI_wrreg_e;
    input               UDI_ri_e;
    input               UDI_stall_m;
    input               UDI_present;
    input               UDI_honor_cee;
    input               UDI_irvalid_e;      
    input [31:0]        UDI_rs_e;               
    input [31:0]        UDI_rt_e;
    input               UDI_endianb_e;
    input               UDI_kill_m;
    input               UDI_start_e;
    input               UDI_run_m;    

    output [31:0]       UDI_rd_buf_m;    
    output [4:0]        UDI_wrreg_buf_e;
    output              UDI_ri_buf_e;
    output              UDI_stall_buf_m;
    output              UDI_present_buf;
    output              UDI_honor_cee_buf;

// BEGIN Wire declarations made by MVP
wire UDI_present_buf;
wire [4:0] /*[4:0]*/ UDI_wrreg_buf_e;
wire [31:0] /*[31:0]*/ UDI_rd_buf_m;
wire UDI_honor_cee_buf;
wire UDI_ri_buf_e;
wire UDI_stall_buf_m;
// END Wire declarations made by MVP


    assign {UDI_rd_buf_m[31:0],    
     UDI_wrreg_buf_e[4:0],
     UDI_ri_buf_e,
     UDI_stall_buf_m,
     UDI_present_buf,
     UDI_honor_cee_buf} = {UDI_rd_m[31:0],    
                           UDI_wrreg_e[4:0],
                           UDI_ri_e,
                           UDI_stall_m,
                           UDI_present,
                           UDI_honor_cee};
                           
//verilint 240 on  // Unused input
endmodule // m14k_udi_scanio_stub
