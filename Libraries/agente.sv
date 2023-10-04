//Agente-Generador
`timescale 1ns/100ps
`include "transacciones_interface.sv"
class agente #(parameter pkg_size = 16, parameter drvrs=4);
    trans_bushandler_mbx test_agente_trans_mbx; 
    trans_sb_mbx agente_scoreboard_mbx;
    trans_bushandler_mbx agente_driver_mbx;
    comando_test_agente_mbx test_agente_mbx ; 
    int max_retardo;
    
    int num_transacciones;
    
    instrucciones_agente tipo_instruccion; 
    trans_bushandler #(.pkg_size(pkg_size)) transaccion_driver;
    trans_sb #(.pkg_size(pkg_size), .drvrs(drvrs)) trans_agente_sb;
    function new;
        max_retardo=20;
    endfunction
task  mailboxes_put();
    #1
       this.transaccion_driver.print(); 
       this.agente_driver_mbx.put(this.transaccion_driver); 
       this.trans_agente_sb=new;  
       this.trans_agente_sb.dato_enviado=transaccion_driver.dato;
       this.trans_agente_sb.tiempo_push=$time;
       this.trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
       this.trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
       this.agente_scoreboard_mbx.put(trans_agente_sb);

        
        
endtask

/*task broadcast_do();
    
    $display("ejecutando broadcast");
    
    for (int i=0; i<this.drvrs; i=i+1) begin
        automatic int k=i;
        #1
        this.transaccion_driver.dispositivo_rx=k;
        $display("###########################################");
        $display(this.transaccion_driver); 
        $display("############################################");
        this.agente_driver_mbx.put(this.transaccion_driver);
        this.trans_agente_sb=new;  
        this.trans_agente_sb.dato_enviado=transaccion_driver.dato;
        this.trans_agente_sb.tiempo_push=$time;
        this.trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
        this.trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
        this.agente_scoreboard_mbx.put(trans_agente_sb);

             
    
    end


endtask */ //Originalmente esta tarea haria los broadcast manualmente, no es necesario   


task InitandRun;    
    int trans_realizadas=0;
    int trans_restantes;
    $display("Inicializando agente en [%g], pkg_size %g y drvrs %g", $time, this.pkg_size, this.drvrs);
    begin
    #1
    //$display ("Pruebas a realizar %g", num_transacciones);
    trans_restantes=test_agente_mbx.num(); //Obteniendo numero de cosas en el mailbox
    $display("Transacciones Restantes %g", trans_restantes);
    if(trans_restantes>0) begin 
        
        $display("Instruccion recibida en [%g]", $time);
        test_agente_mbx.get(tipo_instruccion);
        case(tipo_instruccion)
            llenado_aleatorio: begin
                num_transacciones=5;            
                $display ("Llenando aleatoriamente a partir de [%g]", $time);
                for (int i=0; i<num_transacciones; i++) begin
                    #1   
                    
                    $display("Transacciones Realizadas %g | Transacciones restantes %g", trans_realizadas, num_transacciones-trans_realizadas); //Para llevar control 
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;
                    transaccion_driver.max_retardo=30;
                    transaccion_driver.randomize(); 
                    transaccion_driver.tipo=push;
                    transaccion_driver.update_D_push;
                    mailboxes_put();
                   /* if (this.broadcast_check()) begin 
                        $display("Haciendo broadcast");
                        
                    end else begin
                    
                        transaccion_driver.print(); 
                        agente_driver_mbx.put(transaccion_driver); 
                        trans_agente_sb=new;  
                        trans_agente_sb.dato_enviado=transaccion_driver.dato;
                        trans_agente_sb.tiempo_push=$time;
                        trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
                        trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
                        agente_scoreboard_mbx.put(trans_agente_sb);
                    end*/
                    
                    trans_realizadas++;
                    //trans_agent_driver.dato={transacccion.dispositivo_rx, transaccion.dato} concateno
                    //trans_agent_driver.tipo=push
                    
                end
            end
            trans_aleatoria: begin
                    #1 
                    $display ("Generando una transaccion aleatoria en [%g]", $time);
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;

                    transaccion_driver.randomize();
                    transaccion_driver.update_D_push;

                    transaccion_driver.print();
                    
                    agente_driver_mbx.put(transaccion_driver); 

                   

                    trans_agente_sb=new;  
                    trans_agente_sb.dato_enviado=transaccion_driver.dato;
                    trans_agente_sb.tiempo_push=$time;
                    trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
                    trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
                    agente_scoreboard_mbx.put(trans_agente_sb);
                    trans_realizadas++;


                end 

            broadcast: begin
                #1
                $display ("Generando broadcast");
                transaccion_driver=new;
                transaccion_driver.drvrs=drvrs;

                transaccion_driver.randomize();
                transaccion_driver.dispositivo_rx=transaccion_driver.broadcast;
                transaccion_driver.update_D_push;
                transaccion_driver.print();
                mailboxes_put();

                /*agente_driver_mbx.put(transaccion_driver); 

                trans_agente_sb=new;  
                trans_agente_sb.dato_enviado=transaccion_driver.dato;
                trans_agente_sb.tiempo_push=$time;
                trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_scoreboard_mbx.put(trans_agente_sb);*/
                trans_realizadas++;


            end

            broadcast_id: begin
                #1
                $display ("Generando broadcast igual al ID");
                transaccion_driver=new;
                transaccion_driver.drvrs=drvrs;
                transaccion_driver.randomize();
                transaccion_driver.broadcast=transaccion_driver.dispositivo_rx;
                transaccion_driver.tipo=push; 
                $display("Transaccion a entregar");
                transaccion_driver.update_D_push;

                transaccion_driver.print();
                mailboxes_put();
                /*agente_driver_mbx.put(transaccion_driver); 

                trans_agente_sb=new;  
                trans_agente_sb.dato_enviado=transaccion_driver.dato;
                trans_agente_sb.tiempo_push=$time;
                trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_scoreboard_mbx.put(trans_agente_sb);*/
                trans_realizadas++;


            end
            trans_especifica: begin
                #1
                $display ("Generando transaccion especifica");
                transaccion_driver=new;
                test_agente_trans_mbx.get(transaccion_driver);
                transaccion_driver.update_D_push();
                transaccion_driver.print();
                
                agente_driver_mbx.put(transaccion_driver);
                trans_agente_sb=new;
                trans_agente_sb.dato_enviado=transaccion_driver.dato;
                trans_agente_sb.tiempo_push=$time;
                trans_agente_sb.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_sb.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_scoreboard_mbx.put(trans_agente_sb);
                trans_realizadas++;

               
            
            end 

            sec_trans_aleatorias: begin
                for (int i=0; i<5; i++) begin //Randomizar esto
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;
                    transaccion_driver.randomize();
                    transaccion_driver.update_D_push();
                    mailboxes_put();
                
                end
                
            
            
            end
        endcase

        
    end
end
endtask

endclass                


module tb;
    comando_test_agente_mbx test_agente_mb;
    trans_bushandler_mbx test_agente_trans_mb;
    trans_sb_mbx test_scoreboard_mb;
    trans_bushandler_mbx agente_driver_mb;
    agente #(16,8) agente_tb;
    trans_bushandler #(16) transaccion_test_agente;
    instrucciones_agente tipo_instruccion=sec_trans_aleatorias;
    initial begin
        
        test_agente_mb=new();  
        test_agente_trans_mb=new();     
        test_scoreboard_mb=new();
        agente_driver_mb=new();
        agente_tb=new();
         
        test_agente_mb.put(tipo_instruccion);
        agente_tb.test_agente_trans_mbx=test_agente_trans_mb;

        agente_tb.test_agente_mbx= test_agente_mb;
        agente_tb.agente_scoreboard_mbx = test_scoreboard_mb;
        agente_tb.agente_driver_mbx=agente_driver_mb;
        $display("agente_tb %g", agente_tb.pkg_size);
        transaccion_test_agente=new();
        transaccion_test_agente.drvrs=8;
        transaccion_test_agente.randomize();
        transaccion_test_agente.dato=14;
        transaccion_test_agente.update_D_push();
        test_agente_trans_mb.put(transaccion_test_agente);
        
        agente_tb.InitandRun();
        $display("###################################Desplegando Mailbox de Scoreboard################################");
        while (test_scoreboard_mb.num()>0) begin
            trans_sb transaccion;
            test_scoreboard_mb.get(transaccion);
            $display("Transaccion en mailbox de scoreboard");
            transaccion.print("");
        end
        $display ("###########################Desplegando Mailbox del Driver######################################");
        while (agente_driver_mb.num()>0) begin
            trans_bushandler trans_recibida;
            agente_driver_mb.get(trans_recibida);
            $display("Transaccion en mailbox de driver");
            trans_recibida.print();
        end
end
endmodule

                    
                    
                    
                    








        

 
