class driver_monitor #(parameter drvrs = 4, parameter pkg_size = 16);

    bit pop;
    bit push;
    bit rst;
    bit pndng_bushandler;
    bit pndng_mntr;
    bit [pkg_size-1:0] data_bushandler_i;
    bit [pkg_size-1:0] data_bushandler_o;
    bit [pkg_size-1:0] fifo_in [$];
    bit [pkg_size-1:0] fifo_out [$];
    int tx;
  
    virtual bushandler_if #( .drvrs(drvrs), .pkg_size(pkg_size)) vif;
  
    function new (input int identificador);
        this.pop = 0;
        this.push = 0;
      	this.pndng_bushandler = 0;
        this.pndng_mntr = 0;
     	this.data_bushandler_i = 0;
      	this.data_bushandler_o = 0;
        this.fifo_in = {};
      	this.fifo_out = {};
        this.tx = identificador;
    endfunction
  
    task actualizar_drvr();
	forever begin
        
	    @(negedge vif.clk);
	    //hasta aqui entra
        $display("antes",pop);
        pop = vif.pop[0][tx];
        $display("despues",pop);
	    vif.pndng[0][tx] = pndng_bushandler;
        end
    endtask

    task actualizar_mntr();
	forever begin
	    @(negedge vif.clk);
	    push = vif.push[0][tx];
        end
    endtask
 
  
    task enviar_data_bushandler();
	forever begin
	    @(posedge vif.clk);
	    vif.d_pop[0][tx] = fifo_in[$];
	    if (pop) begin
    	        fifo_in.pop_back();
	    end

	    if (fifo_in.size() != 0) 
                pndng_bushandler = 1;
            else
                pndng_bushandler = 0;
	end
    endtask

    task recibir_data_bushandler();
	forever begin
	    @(posedge vif.clk);
	    if (push) begin
	        fifo_out.push_front(vif.d_push[0][tx]);
	    end
      
	    if (fifo_out.size() != 0) begin 
                pndng_mntr = 1;
	    end
            else
                pndng_mntr = 0;
	end
    endtask     



    

    function void print();
        $display("---------------------------");
        $display("[TIME %g]", $time);
        $display("push=%b", this.push);
        $display("pop=%b", this.pop);
        $display("pndng_bushandler=%b", this.pndng_bushandler);
        $display("pndng_monitor=%b", this.pndng_mntr);
        $display("data_bushandler_i=%h", this.data_bushandler_i);
        $display("data_bushandler_o=%h", this.data_bushandler_o);
        $display("fifo_in=%p", this.fifo_in);
        $display("fifo_out=%p", this.fifo_out);
        $display("tx=%d", this.tx);
        $display("---------------------------");

    endfunction
endclass

    
class driver_monitor_hijo #( parameter drvrs = 4, parameter pkg_size = 16);
    driver_monitor #( .drvrs(drvrs), .pkg_size(pkg_size)) dm_hijo;
    //virtual bus_if #( .drvrs(drvrs), .pckg_sz(pckg_sz)) vif_hijo;
    //Definiendo las transacciones
    trans_bushandler #( .pkg_size(pkg_size)) transaccion;
    trans_bushandler #( .pkg_size(pkg_size)) transaccion_mntr;

    //Defieniendo los mbx
    trans_bushandler_mbx #( .pkg_size(pkg_size)) agente_driver_mbx;
   // trnas_bushandler_mbx #( .pkg_size(pkg_size)) drvr_chkr_mbx;
    trans_bushandler_mbx #(.pkg_size(pkg_size)) monitor_checker_mbx;



    int espera;
    int tx;
    
    function new (input int identification);
      	dm_hijo = new(identification);
      	//dm_hijo.vif = vif_hijo;
        tx = identification;
	    transaccion = new();
	   // transaccion_mntr = new(.tpo(lectura));
        transaccion_mntr = new();
        transaccion_mntr.tipo = pop;
	    agente_driver_mbx = new();
//	drvr_chkr_mbx = new();
	    monitor_checker_mbx = new();
    endfunction
    
    task ejecutando_drvr();
    	$display("[tx] %d", tx);
        $display("[%g] El Driver fue inicializado", $time);
	fork
        $display("actualizando el driver para enviar dato");
        dm_hijo.actualizar_drvr();
	    dm_hijo.enviar_data_bushandler();
	join_none
        @(posedge dm_hijo.vif.clk);
        forever begin
            $display("reset de hijo en envio");
            dm_hijo.vif.reset = 0;
	        espera = 0;
            
	        agente_driver_mbx.get(transaccion);
	        while(espera <= transaccion.retardo) begin
	            @(posedge dm_hijo.vif.clk);
		        espera = espera + 1;
	        end
                
            if (transaccion.tipo == push) begin
                $display("[ESCRITURA]");
		        transaccion.tiempo = $time;
                dm_hijo.fifo_in.push_front(transaccion.dato); //revisar 
		        transaccion.print("[DEBUG] Dato enviado");
            end
        end
    endtask

    task ejecutando_mntr();
    	$display("[tx] %d", tx);
        $display("[%g] El Monitor fue inicializado", $time);
	
	fork
        $display("actualizando monir para recibir dato");
        dm_hijo.actualizar_mntr();
	    dm_hijo.recibir_data_bushandler();
	join_none
        
	forever begin
            $display("reset de hijo");
            dm_hijo.vif.reset = 0;
            @(posedge dm_hijo.vif.clk);    
	    if (dm_hijo.pndng_mntr) begin
	    	$display("[LECTURA]");
	    	transaccion_mntr.tiempo = $time;
		    transaccion_mntr.dato = dm_hijo.fifo_out.pop_back();
		    monitor_checker_mbx.put(transaccion_mntr);
		    transaccion.print("[DEBUG] Dato recibido");
	    end
        end
    endtask
endclass
