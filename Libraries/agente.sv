//Agente-Generador
`include "transacciones_interface.sv"
class agente #(parameter pkg_size = 16, parameter drvrs=4);
   
    trans_sb_mbx agente_scoreboard_mbx;
    trans_bushandler_mbx agente_driver_mbx;
    comando_test_agente_mbx test_agente_mbx ; 
    int max_retardo;
    
    
    int num_transacciones;
    instrucciones_agente tipo_instruccion; 
    trans_bushandler #(.pkg_size(pkg_size)) transaccion;
    trans_sb #(.pkg_size(pkg_size)) trans_agente_sb;
    function new;
        max_retardo=20;
    endfunction
     

task InitandRun;    
    int trans_realizadas=0;
    int trans_restantes;
    $display("Inicializando agente en [%g]", $time);
    begin
    #1
    $display ("Pruebas a realizar %g", num_transacciones);
    trans_restantes=test_agente_mbx.num(); //Obteniendo numero de cosas en el mailbox
    if(trans_restantes>0) begin 
        $display("Instruccion recibida en [%g]", $time);
        test_agente_mbx.get(tipo_instruccion);
        case(tipo_instruccion)
            llenado_aleatorio: begin
                num_transacciones=20;            
                $display ("Llenando aleatoriamente a partir de [%g]", $time);
                for (int i=0; i<num_transacciones; i++) begin
                   
                    
                    $display("Transacciones Realizadas %g | Transacciones restantes %g", trans_realizadas, trans_restantes-trans_realizadas); //Para llevar control 

                    transaccion=new;
                    transaccion.tipo=push;
                    transaccion.max_retardo=30;
                    transaccion.randomize_data();
                    transaccion.randomize(); 
                    
                   
                    trans_agente_sb=new;  
                    trans_agente_sb.dato_enviado=transaccion.dato;
                    trans_agente_sb.tiempo_push=$time;
                    trans_agente_sb.drvr_rx=transaccion.dispositivo_rx;
                    trans_agente_sb.drvr_tx=transaccion.dispositivo_tx;
                    agente_scoreboard_mbx.put(trans_agente_sb);

                    trans_realizadas++;
                    
                    //trans_agent_driver.dato={transacccion.dispositivo_rx, transaccion.dato} concateno
                    //trans_agent_driver.tipo=push
                    
                end
            end
        endcase
    end
end
endtask

endclass                


module tb;
    comando_test_agente_mbx test_agente_mb;
    agente #(16,4) agente_tb;
    
    initial begin
        instrucciones_agente tipo_instruccion =llenado_aleatorio;
        test_agente_mb.put(tipo_instruccion);
        agente_tb.test_agente_mbx=test_agente_mb;

        $display("Hola");
    end
endmodule

                    
                    
                    
                    








        

 
