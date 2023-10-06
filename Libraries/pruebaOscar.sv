`timescale 1ns / 1ps
`default_nettype none
`include "Library.sv"
`include "transacttionsOscar.sv"
`include "driver_monitorOscar.sv"
`include "checkerOscar.sv"

module DUT_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 2;
    parameter bits = 1;
    parameter drvrs = 4;
    parameter pckg_sz = 8;
    parameter broadcast = {8{1'b1}} ;

    bit CLK_100MHZ;                                     //in
    
    //drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_UT [drvrs];
    strt_drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_monitor_inst;

    checker_p #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mi_chkr; 

    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
   bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;

   sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx; 

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans [8];

    bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if (.clk(CLK_100MHZ));
    always #(PERIOD/2) CLK_100MHZ=~CLK_100MHZ;
    
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) bus_DUT
    (
        .clk    (_if.clk),
        .reset  (_if.reset),
        .pndng  (_if.pndng),
        .push   (_if.push),
        .pop    (_if.pop),
        .D_pop  (_if.D_pop),
        .D_push (_if.D_push)
    );
    
    initial begin
      	CLK_100MHZ = 0;
      	
	agnt_drvr_mbx = new();
	drvr_chkr_mbx = new();
	mntr_chkr_mbx = new();
chkr_sb_mbx = new();


        $display("INICIO");
	mi_chkr = new();
	driver_monitor_inst = new();

        for (int i = 0; i<drvrs; i++) begin
            $display("[%d]", i);
	    driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if;
	    driver_monitor_inst.strt_dm[i].agnt_drvr_mbx = agnt_drvr_mbx;
	    driver_monitor_inst.strt_dm[i].drvr_chkr_mbx = drvr_chkr_mbx;
	    driver_monitor_inst.strt_dm[i].mntr_chkr_mbx = mntr_chkr_mbx;
            #1;
        end
	mi_chkr.drvr_chkr_mbx = drvr_chkr_mbx;
	mi_chkr.mntr_chkr_mbx = mntr_chkr_mbx;
mi_chkr.chkr_sb_mbx = chkr_sb_mbx;
	
	trans[0] = new(.dto(16'h01));
	trans[1] = new(.dto(16'h00));
	trans[2] = new(.dto(16'h03));
	trans[3] = new(.dto(16'h02));

	agnt_drvr_mbx.put(trans[0]);
	agnt_drvr_mbx.put(trans[1]);
	agnt_drvr_mbx.put(trans[2]);
	agnt_drvr_mbx.put(trans[3]);

	_if.reset = 1;
	#1;
	_if.reset = 0;	
        

	fork
	    driver_monitor_inst.start_driver();
	    driver_monitor_inst.start_monitor();
	    mi_chkr.update();
	    mi_chkr.check();
	join_none


        $display("FIN");

        
    end
endmodule
