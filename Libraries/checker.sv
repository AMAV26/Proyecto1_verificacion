//`include "transacciones_interface.sv"
class Checker #(parameter pkg_size=16, parameter drvrs=8);
    trans_bushandler #(.pkg_size(pkg_size)) transaccion_driver;
    trans_sb #(.pkg_size(pkg_size)) trans_agente_checker;

	trans_sb_mbx agente_checker_mbx;
	trans_sb_mbx checker_scoreboard_mbx;
    trans_bushandler_mbx monitor_checker_mbx;
    
 task run;
	$display("[%g] El checker fue inicializado",$time);
    transaccion_driver=new(); 
    trans_agente_checker=new();
    forever begin
        fork 
            agente_checker_mbx.get(trans_agente_checker);
            monitor_checker_mbx.get(transaccion_driver);
        join    
        $display("Checker: Se recibio el dato del DUT");
        if(trans_agente_checker.tipo_transaccion!=pop) begin
            if(trans_agente_checker.dato_enviado == transaccion_driver.D_push) begin
			    $display("Checker: Transaccion recibida");
   		        checker_scoreboard_mbx.put(trans_agente_checker);
            end
		end
        if (trans_agente_checker.tipo_transaccion==pop) begin
           if (trans_agente_checker.drvr_rx==transaccion_driver.dispositivo_rx) begin
                $display("Pop realizado correctamente");
                trans_agente_checker.dato_enviado=transaccion_driver.D_push;
                checker_scoreboard_mbx.put(trans_agente_checker);
           end
        end
		else $display("Checker: Error en el dato");
	end
endtask
endclass	
/*
module tb;
Checker #(16,8) checker_tb;
trans_sb_mbx agente_checker_mb;
trans_sb_mbx monitor_scoreboard_mb;
trans_bushandler_mbx monitor_checker_mb;
trans_bushandler #(16) transaccion_monitor;
trans_sb #(16) transaccion_agente;
initial begin
        agente_checker_mb=new();
        monitor_scoreboard_mb=new();
        monitor_checker_mb=new();
        checker_tb=new();
        transaccion_agente=new();
        transaccion_agente.randomize();
        transaccion_agente.dato_enviado=3;
        transaccion_monitor=new();
        transaccion_monitor.D_push=3;
        checker_tb.agente_checker_mbx=agente_checker_mb;
        checker_tb.checker_scoreboard_mbx=monitor_scoreboard_mb;
        checker_tb.monitor_checker_mbx=monitor_checker_mb; 
        monitor_checker_mb.put(transaccion_monitor);
        agente_checker_mb.put(transaccion_agente);
        checker_tb.run();
    end
    endmodule
*/
    
