class test #(parameter pkg_size = 16, parameter drvrs= 4);
    comando_test_agente_mbx test_agente_mbx;
    rand int num_transacciones;
    constraint num_transacciones_max {num_transacciones < 25; num_transacciones>1;}
    parameter max_retardo=20;
    rand int casos;
    constraint casos_const {casos<6;}
    solicitud_sb solicitud_scoreboard;
    instrucciones_agente instruccion_agente;
    trans_bushandler transaccion_test_agente;
    trans_bushandler_mbx transaccion_test_agente_mbx;
    //Implementar Ambiente
    instrucciones_agente caso;
    int primer_num;
    function new;
        test_agente_mbx=new();
        transaccion_test_agente_mbx=new();
    endfunction
    function instrucciones_agente randomizar_transacciones;
        reg [2:0] escoge_casos;
        escoge_casos=this.casos;
        case(escoge_casos)
            0: begin
                return trans_aleatoria;

            end
            1: begin
                return llenado_aleatorio;
            end
            2: begin
                return sec_trans_aleatorias;

            end
            3: begin
                return broadcast;
            end
            4: begin
                return broadcast_id;
            end
        endcase
    

    endfunction
    task run;
        #10
        $display("[%g] Inicializando Test", $time);
        this.randomize();
        $display("Numero de transacciones a realizar %g", num_transacciones);
        this.primer_num=this.num_transacciones;
        for (int i=0; i<primer_num; i++) begin
            #1
            this.randomize();
            caso=this.randomizar_transacciones;
            this.test_agente_mbx.put(caso); 
            $display("Transaccion introducida en el mailbox %g", $time);
        end
        $display("Transacciones enviadas al driver, ejecutando pops");
        caso=pop_general;
        this.test_agente_mbx.put(caso);
        
    endtask

endclass

 

