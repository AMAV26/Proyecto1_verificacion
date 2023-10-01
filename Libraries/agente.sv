//Agente-Generador

class agente (#parameter pkg_size = 16, parameter drvrs=4;)
         //Preguntar tipo de transacción adecuada para comunicación agente driver
    test_agente_mbx //Preguntar tipo de mbx adecuada para comunicación test agente
    int num_transacciones;
    tipo_trans instrucciones_agente; //supongo
    bit [pkg_size-1:0] dto_spec
    trans_bushandler #(.pkg_size(pkg_size)) transaccion;
    int numero; 


task InitandRun;
    int trans_realizadas=0;
    $display("Inicializando agente en [%g]", $time)
    begin
    #1
    cantidad=//Introducir numero de pruebas
    $display ("Pruebas a realizar %g", cantidad);
    int trans_restantes=test_agente_mbx.num();
    if(trans_restantes>0) begin //Buscar metodo de mailboxes para saber si está empty, num devuelve el numero de transacciones. 
        $display("Instruccion recibida en [%g]", time)
        test_agente_mbx.get(instrucciones_agente);
        case(instrucciones_agente)
            llenado_aleatorio begin:
                for int i=0; i<num_transacciones, i++ begin
                    $display("Transacciones Realizadas %g | Transacciones restantes %g", trans_realizadas, trans_realizadas); //Para llevar control 
                    $display ("Llenando aleatoriamente a partir de [%g]");
                    transaccion.new;
                    transaccion.max_retardo=max_retardo
                    transaccion.







        