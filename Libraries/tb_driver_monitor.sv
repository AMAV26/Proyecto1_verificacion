`timescale 1ns / 1ps
`default_nettype none
`include "Library.sv"
`include "transacciones_interface.sv"
`include "driver_monitor.sv"

module DUT_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 2;
    parameter bits = 1;
    parameter drvrs = 4;
    parameter pkg_size = 8;
    parameter broadcast = {8{1'b1}} ;

    bit CLK_100MHZ;                                     //in
    
    driver_monitor_hijo #( .drvrs(drvrs), .pkg_size(pkg_size)) driver_UT [drvrs];

    trans_bushandler_mbx #( .pkg_size(pkg_size)) agente_driver_mbx;
   //trans_bushandler_mbx #( .pkg_size(pkg_size)) drvr_chkr_mbx;
    trans_bushandler_mbx #( .pkg_size(pkg_size)) monitor_checker_mbx;

    trans_bushandler #( .pkg_size(pkg_size)) trans [8];

    bushandler_if #( .drvrs(drvrs), .pkg_size(pkg_size)) _if (.clk(CLK_100MHZ));
    always #(PERIOD/2) CLK_100MHZ=~CLK_100MHZ;
    
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pkg_size), .broadcast(broadcast)) bus_DUT
    (
        .clk    (_if.clk),
        .reset  (_if.reset),
        .pndng  (_if.pndng),
        .push   (_if.push),
        .pop    (_if.pop),
        .D_pop  (_if.d_pop),
        .D_push (_if.d_push)
    );
    
    initial begin
      	CLK_100MHZ = 0;
      	
	    agente_driver_mbx = new();
	    //drvr_chkr_mbx = new();
	    monitor_checker_mbx = new();

        $display("INICIO");
        for (int i = 0; i<drvrs; i++) begin
            $display("[%d]", i);
            driver_UT[i] =new(i);
	        driver_UT[i].dm_hijo.vif = _if;
	        driver_UT[i].agente_driver_mbx = agente_driver_mbx;
	        //driver_UT[i].drvr_chkr_mbx = drvr_chkr_mbx;
	        driver_UT[i].monitor_checker_mbx = monitor_checker_mbx;
            #1;
        end
	
	    trans[0] = new(.dato(16'h01));
	    trans[1] = new(.dato(16'h00));
	    trans[2] = new(.dato(16'h03));
	    trans[3] = new(.dato(16'h02));

	    agente_driver_mbx.put(trans[0]);
	    agente_driver_mbx.put(trans[1]);
	    agente_driver_mbx.put(trans[2]);
	    agente_driver_mbx.put(trans[3]);
        trans[2].print();
	    _if.reset = 1;
	    #1;
        _if.reset = 0;	
        
	for (int i = 0; i<drvrs; i++) begin
	    fork
		automatic int j = i;
		begin
		    driver_UT[j].ejecutando_drvr();
		end
	    join_none
 	   /* fork
		automatic int j = i;
		begin
		    driver_UT[j].ejecutando_mntr();
		end
            join_none*/
	end

        $display("FIN");

        
    end
endmodule
