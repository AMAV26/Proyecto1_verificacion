`timescale 1ns/1ps
`include "transacciones_interface.sv"
`include "agente.sv"
`include "test.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "driver_monitor_chabez.sv"
`include "Library.sv"
`include "monitor.sv"
module tb;
reg clk;
test test_tb;
comando_test_agente_mbx test_agente_mb;
trans_bushandler_mbx agente_driver_mb;
agente #(16,4) agente_tb;
Checker #(16,4) checker_tb;
scoreboard #(16,4) scoreboard_tb;
trans_sb_mbx agente_checker_mb; 
trans_sb_mbx checker_scoreboard_mb;
comando_test_sb_mbx test_scoreboard_mb;
driver #(16,4) driver_tb;
monitor #(16,4) monitor_tb;
trans_bushandler_mbx monitor_checker_mb;
//always #5 clk=-clk;
//always@(posedge clk)begin
  //  $display("AAAAAAAAAAAAAA");
   // if ($time > 500)begin
	 //   $display("Testbench: Tiempo limite de prueba en el testbench alcanzado");
//		$finish;
//	end
//end
bit clk;
bushandler_if #(4 ,16) vif (.clk(clk));
bs_gnrtr_n_rbtr #(1, 4, 16, 11111111) bus_DUT
    (
        .clk    (vif.clk),
        .reset  (vif.reset),
        .pndng  (vif.pndng),
        .push   (vif.push),
        .pop    (vif.pop),
        .D_pop  (vif.d_pop),
        .D_push (vif.d_push)
    );
initial begin;
    monitor_tb=new();
    monitor_checker_mb=new();
    driver_tb=new();
    test_agente_mb=new();
    test_scoreboard_mb=new();
    agente_tb=new(); 
    test_tb=new();
    checker_tb=new();
    scoreboard_tb=new();
    agente_checker_mb=new();
    agente_driver_mb=new();
    checker_scoreboard_mb=new();
    test_tb.test_agente_mbx=test_agente_mb;
    test_tb.transaccion_test_sb_mbx=test_scoreboard_mb; 
    agente_tb.agente_checker_mbx=agente_checker_mb;
    agente_tb.agente_driver_mbx=agente_driver_mb;
    agente_tb.test_agente_mbx=test_agente_mb;
    checker_tb.agente_checker_mbx=agente_checker_mb;
    checker_tb.monitor_checker_mbx=monitor_checker_mb;
    checker_tb.checker_scoreboard_mbx=checker_scoreboard_mb;
    scoreboard_tb.checker_scoreboard_mbx=checker_scoreboard_mb;
    scoreboard_tb.tst_sb_mbx=test_scoreboard_mb;
    driver_tb.vif=vif;
    driver_tb.agente_driver_mbx=agente_driver_mb; 
    monitor_tb.vif=vif;
    monitor_tb.monitor_checker_mbx=monitor_checker_mb;
    /*while (test_agente_mb.num()>0) begin
            instrucciones_agente trans_recibida;
            test_agente_mb.pee(trans_recibida);
            $display("Transaccion en mailbox de agente");
            $display(trans_recibida);
    end*/
   fork
    test_tb.run();
   join_none
   fork 
        agente_tb.InitandRun();
    join_none
   fork 
       checker_tb.run();
    join_none
    fork
        scoreboard_tb.run();
    join_none
    fork 
        driver_tb.run();
    join_none   
    fork
       monitor_tb.run();
   join_none 
end    
endmodule    
