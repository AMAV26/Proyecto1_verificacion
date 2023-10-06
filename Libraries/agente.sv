//Agente-Generador
//`include "transacciones_interface.sv"
class agente #(parameter pkg_size = 16, parameter drvrs=4);
    trans_bushandler_mbx test_agente_trans_mbx; 
    trans_sb_mbx agente_checker_mbx;
    trans_bushandler_mbx agente_driver_mbx;
    comando_test_agente_mbx test_agente_mbx ; 
    int max_retardo;
    rand int num_transacciones_aleatorias;
    rand int numero_aleatorio;
    instrucciones_agente tipo_instruccion; 
    trans_bushandler #(.pkg_size(pkg_size)) transaccion_driver;
    trans_sb #(.pkg_size(pkg_size), .drvrs(drvrs)) trans_agente_checker;
    string linea_csv, d_enviado,s_tx,s_rx,s_tp;
    function new;
        max_retardo=20;
    endfunction

    constraint numero_aleatorio_const {numero_aleatorio>1; numero_aleatorio<7;} 
    constraint num_transacciones_aleatorias_const {num_transacciones_aleatorias>10; num_transacciones_aleatorias<30;}
task  mailboxes_put();
    #1
       this.agente_driver_mbx.put(this.transaccion_driver);// Pongo la transaccion en el mailbox respectivo (hacia el driver) 
       this.trans_agente_checker=new;  
       this.trans_agente_checker.dato_enviado=transaccion_driver.D_push;//Introduzco el paquete en la transaccion que va al checker
       this.trans_agente_checker.tiempo_push=$time;
       this.trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
       this.trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
       this.trans_agente_checker.tipo_transaccion=transaccion_driver.tipo;//Introduzco toda la informacion necesaria en la transaccion para el checker
       if (this.transaccion_driver.dispositivo_rx==this.transaccion_driver.broadcast) begin
            this.broadcast_do();//En caso de que haya un broadcast corro este task
       end
        else begin
            d_enviado.hextoa(this.transaccion_driver.D_push);
            s_rx.hextoa(this.transaccion_driver.dispositivo_rx);
            s_tx.hextoa(this.transaccion_driver.dispositivo_tx);
            s_tp.hextoa(this.transaccion_driver.tipo);
            linea_csv= {d_enviado,",",s_tx,",",s_rx,",",s_tp};
            $system($sformatf("echo %0s >> agente.csv", linea_csv));//Introduzco la informacion relevante al csv, esto en caso de que no haya broadcast
            this.agente_checker_mbx.put(trans_agente_checker);
        end 
        







                      
        
endtask

task broadcast_do();
    
    $display("ejecutando broadcast");
    
    for (int i=0; i<this.drvrs; i=i+1) begin
        automatic int k=i;
        #1
        this.transaccion_driver.dispositivo_rx=k;
        $display("###########################################");
        $display(this.transaccion_driver); 
        $display("############################################");
        this.agente_driver_mbx.put(this.transaccion_driver);
        this.trans_agente_checker=new;  
        this.trans_agente_checker.dato_enviado=transaccion_driver.dato;
        this.trans_agente_checker.tiempo_push=$time;
        this.trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
        this.trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
        this.agente_checker_mbx.put(trans_agente_checker);//Se hace lo mismo que cuando no hay broadcast, pero una vez para cada uno de los drivers
        d_enviado.hextoa(this.transaccion_driver.D_push);
        s_rx.hextoa(this.transaccion_driver.dispositivo_rx);
        s_tx.hextoa(this.transaccion_driver.dispositivo_tx);
        s_tp.hextoa(this.transaccion_driver.tipo);//Convierto los numeros a hexadecimales
        linea_csv= {d_enviado,",",s_tx,",",s_rx,",",s_tp};
        $system($sformatf("echo %0s >> agente.csv", linea_csv));

             
    
end


endtask    


task InitandRun;   
    int trans_realizadas=0;
    int trans_restantes;
    this.randomize();     
    $system("echo dato,transmisor,receptor,tipo,t_pop,t_push > agente.csv");//Envio el header del csv
    $display("Inicializando agente en [%g], pkg_size %g y drvrs %g", $time, this.pkg_size, this.drvrs);//Inicializo el agente
    begin
    #1
    //$display ("Pruebas a realizar %g", num_transacciones);
    trans_restantes=test_agente_mbx.num(); //Obteniendo numero de cosas en el mailbox
    while (trans_restantes==0) begin
        
        #1    
        trans_restantes=test_agente_mbx.num();//Esto es para  esperar a que llegue una transaccion
        if (trans_restantes==0) begin
            $display("Sin transacciones en el agente %g", $time);
    end    
    end
    while(trans_restantes>0) begin 
        $display(trans_restantes); 
        $display("Transacciones Restantes %g", trans_restantes);
        $display("Instruccion tomada del mailbox en [%g]", $time);
        test_agente_mbx.get(tipo_instruccion);//Se toma la instruccion del mailbox del test
        case(tipo_instruccion)
            llenado_aleatorio: begin
                $display ("Llenando aleatoriamente a partir de [%g]", $time);
                for (int i=0; i<num_transacciones_aleatorias; i++) begin
                    #1   
                    
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;
                    transaccion_driver.max_retardo=30;
                    transaccion_driver.randomize(); //Introduzco transacciones aleatorias a los mailboxes
                    transaccion_driver.tipo=push;//Como es llenado, todas las transacciones de este for son pushes
                    transaccion_driver.update_D_push;
                    transaccion_driver.print();//Imprimo la transaccion, solo por sanidad
                    mailboxes_put();//Lo pongo en mailboxes
                   /* if (this.broadcast_check()) begin 
                        $display("Haciendo broadcast");
                        
                    end else begin
                    
                        transaccion_driver.print(); 
                        agente_driver_mbx.put(transaccion_driver); 
                        trans_agente_checker=new;  
                        trans_agente_checker.dato_enviado=transaccion_driver.dato;
                        trans_agente_checker.tiempo_push=$time;
                        trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
                        trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
                        agente_checker_mbx.put(trans_agente_checker);
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
                    transaccion_driver.randomize();//Hago una transaccion totalmente aleatoria
                    transaccion_driver.update_D_push;
                    transaccion_driver.print();
                    mailboxes_put();
                   

                    trans_realizadas++;


                end 

            broadcast: begin
                #1
                $display ("Generando broadcast");
                transaccion_driver=new;
                transaccion_driver.drvrs=drvrs;

                transaccion_driver.randomize();
                transaccion_driver.dispositivo_rx=transaccion_driver.broadcast;//Hago una transaccion aleatoria, pero con el id siendo igual a broadcast
                transaccion_driver.update_D_push;
                transaccion_driver.print();
                mailboxes_put();

                /*agente_driver_mbx.put(transaccion_driver); 

                trans_agente_checker=new;  
                trans_agente_checker.dato_enviado=transaccion_driver.dato;
                trans_agente_checker.tiempo_push=$time;
                trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_checker_mbx.put(trans_agente_checker);*/
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
                $display("Transaccion a entregar");//Igualo el valor de broadcast de la transaccion al de un id
                transaccion_driver.update_D_push;

                transaccion_driver.print();
                mailboxes_put();
                /*agente_driver_mbx.put(transaccion_driver); 

                trans_agente_checker=new;  
                trans_agente_checker.dato_enviado=transaccion_driver.dato;
                trans_agente_checker.tiempo_push=$time;
                trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_checker_mbx.put(trans_agente_checker);*/
                trans_realizadas++;


            end
            /*trans_especifica: begin
                #1
                $display ("Generando transaccion especifica");
                transaccion_driver=new;
                test_agente_trans_mbx.get(transaccion_driver);
                transaccion_driver.update_D_push();
                transaccion_driver.tipo=push;
                transaccion_driver.print();
                
                agente_driver_mbx.put(transaccion_driver);
                trans_agente_checker=new;
                trans_agente_checker.dato_enviado=transaccion_driver.dato;
                trans_agente_checker.tiempo_push=$time;
                trans_agente_checker.drvr_rx=transaccion_driver.dispositivo_rx;
                trans_agente_checker.drvr_tx=transaccion_driver.dispositivo_tx;
                agente_checker_mbx.put(trans_agente_checker);
                trans_realizadas++;

               
            
            end*/ 

            sec_trans_aleatorias: begin
                    $display("Generando secuencia de transacciones aleatorias");//Este caso es igual que transaccion aleatoria, pero en multiples
                    this.randomize();
                    $display("Numero de transacciones aleatorias a realizar: %g", this.numero_aleatorio);
                    for (int i=0; i<numero_aleatorio; i++) begin
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;
                    transaccion_driver.randomize();
                    transaccion_driver.update_D_push();
                    transaccion_driver.print();
                    mailboxes_put();
                end
            end 
            pop_general: begin
                    $display("Ejecutando Pops aleatorios");
                    for  (int i=0; i<10; i++) begin
                    transaccion_driver=new;
                    transaccion_driver.drvrs=drvrs;
                    transaccion_driver.randomize;
                    transaccion_driver.tipo=pop;//Este caso es 10 pops, para asegurar que sucederan pops
                    transaccion_driver.print();
                    mailboxes_put();
                    end
                end            
            
        endcase
        trans_restantes=test_agente_mbx.num();//Reviso las transacciones en caso de que haya nuevas transacciones en el mailbox

    end
end

endtask

endclass                

/*
module tb;
    comando_test_agente_mbx test_agente_mb;
    trans_sb_mbx test_scoreboard_mb;
    trans_bushandler_mbx agente_driver_mb;
    agente #(16,4) agente_tb;
    trans_bushandler #(16) transaccion_test_agente;
    instrucciones_agente tipo_instruccion=0;
    initial begin
        
        test_agente_mb=new();  
        test_scoreboard_mb=new();
        agente_driver_mb=new();
        agente_tb=new();
         
        test_agente_mb.put(tipo_instruccion);

        agente_tb.test_agente_mbx= test_agente_mb;
        agente_tb.agente_checker_mbx = test_scoreboard_mb;
        agente_tb.agente_driver_mbx=agente_driver_mb;
        $display("agente_tb %g", agente_tb.pkg_size);
        transaccion_test_agente=new();
        transaccion_test_agente.drvrs=8;
        transaccion_test_agente.randomize();
        transaccion_test_agente.dato=14;
        transaccion_test_agente.update_D_push();
        
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
endmodule*/

                    
                    
                    
                    








        

 
