//Agente-Generador
`include "transacciones_interface.sv"
class agente #(parameter pkg_size = 16, parameter drvrs=4);
    
    trans_bushandler_mbx agente_scoreboard_mbx;
    trans_bushandler_mbx agente_driver_mbx;
    comando_test_agente_mbx test_agente_mbx ; //Preguntar tipo de mbx adecuada para comunicación test agente
    int max_retardo;
    
    
    int num_transacciones;
    instrucciones_agente tipo_instruccion; 
    bit [pkg_size-1:0] dto_spec
    trans_bushandler #(.pkg_size(pkg_size)) transaccion;
    function new;
        num_transacciones=10;
        max_retardo=20
    endfunction


task InitandRun;    
    int trans_realizadas=0;
    $display("Inicializando agente en [%g]", $time)
    begin
    #1
    $display ("Pruebas a realizar %g", num_transacciones);
    int trans_restantes=comando_test_agent_mbx.num(); //Obteniendo numero de cosas en el mailbox
    if(trans_restantes>0) begin 
        $display("Instruccion recibida en [%g]", time)
        test_agente_mbx.get(tipo_instruccion);
        case(tipo_instruccion)
            llenado_aleatorio: begin
                for int i=0; i<num_transacciones, i++ begin
                    
                    $display("Transacciones Realizadas %g | Transacciones restantes %g", trans_realizadas, trans_realizadas); //Para llevar control 
                    $display ("Llenando aleatoriamente a partir de [%g]");

                    transaccion=new;
                    transaccion.tipo=push;
                    transaccion.max_retardo=30;
                    transaccion.randomize_data();
                    transaccion.randomize(); 
                    transaccion.print();
                    
                    trans_sb trans_agent_sb;
                    trans_agent_sb.dato_enviado=transaccion.dato;
                    trans_agent_sb.tiempo_push=$time;
                    trans_agent_sb.drvr_rx=transaccion.dispositivo_rx;
                    trans_agent_sb.drvr_tx=transacccion.dispositivo_tx;
                    agent_sb_mbx.put(trans_agent_sb);

                    trans_realizadas++;
                    
                    //trans_agent_driver.dato={transacccion.dispositivo_rx, transaccion.dato} concateno
                    //trans_agent_driver.tipo=push
                    
                end
            end
    end
endtask

                




                    
                    
                    
                    








        




        