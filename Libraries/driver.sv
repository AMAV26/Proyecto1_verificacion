class fifo_sim #(parameter pkg_size=16, parameter driver=8);
//deberia hacer un bit broadcast??
     bit pop;
     bit push;
     bit pndng
     bit rst;       
     bit [pkg_size-1:0] D_push;
     bit [pkg_size-1:0] D_pop;
     bit pndng;
     bit [pkg_size-1:0] fifo[$];
     function new;
        this.pop = 0;
        this.push = 0;
        this.pndng = 0;
        this.rst = 0;
    endfunction

    task reset(bit rst)
        if(this.rst ==1) begin
           fifo.delete();
            pndng = 0;
        end     
    endtask

    task push(bit [pckg_sz-1:0] D_push);
        if (this.push==1) begin
           fifo.push_front(D_push);
            pndng = 1;
        end
    endtask

    task pop(bit [pckg_sz-1:0] D_pop);
        if (this.pop==1) begin
            D_pop = fifo.pop_back();
        end if (sim_fifo.size()==0) begin
            pndng = 0;
        end
    endtask
endclass            
class driver_hijo #(parameter drvrs=4, parameter pkg_sizw=16, parameter depth=8, parameter bits=1, parameter broadcast = {8{1'b1}});//deberia poner parameter broadcast??
	fifo_sim #(.pkg_size(pkg_size), .depth(depth)) fifo_in;
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size)) vif; //no defini bits por que en la interface no esta,  igual siempre es uno, mas bien no se si quitarlo como parametro en driver hijos	
	trans_INTERFACE_mbx drvr_dhijo_mbx; //Esta pipi es la interface yhay que hacerl pa nombrarla Mailbox del agente al driver de tipo trans_bus
	trans_INTERFACE #(.width(width)) transaccion;	//depende de la interface/transactions
	
	int retardo_max;
	logic [7:0]rx;//destino
	int tx; //origen DUDA: aqui igual no deberian ser los 8 bits del ID?

	bit [width-1:0]dato;
	bit [width-1:0]d_out;
	int retardo;
	int dest = rx;
	
	function new;
		fifo_in = new();
		drvr_dhijo_mbx = new();
		transaccion = new();
		fifo_in.pndng = 0;		
	endfunction

	task run();
		drvr_dhijo_mbx.peek(transaccion);
		if (tx == transaccion.origen)begin //existe la funcion .origen???	no entiendo donde define este atributo
			$display("[%g] Driver: Cantidad de mensajes a enviar %g",$time,drvr_dhijo_mbx.num());
			drvr_dhijo_mbx.get(transaccion);
			$display(":):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):)");
			$display("[%g] Driver_hijo: Dispositivo %g listo para enviar",$time,origen);
		
			vif.pndng[bits-1][origen] <= 0;
			vif.D_pop[bits-1][origen] <= 0;
			vif.rst    <= 1;
			#2 vif.rst <= 0;
			fifo_in.D_push = transaccion.D_push;
			fifo_in.push();
			fifo_in.pend();

			r = 0;
			while (retardo < retardo_max)begin
				retardo++;
			end
				
	
			fifo_in.pop();
			vif.D_pop[bits-1][origen] <= fifo_in.D_pop;
			vif.pndng[bits-1][origen] <= fifo_in.pndng;
			@(posedge vif.pop[bits-1][tx]);
				$display("[%g] Se envio el mensaje",$time);		
				$display("[%g] D_pop = %b pndng = %b",$time,vif.D_pop[0][tx],vif.pndng[0][tx]);		
		end		
	endtask
endclass
class driver_papi #(parameter pgk_size=16, parameter depth=8, parameter drvrs=4, parameter bits=1, parameter broadcast={8{1'b1}}); 
	virtual bus_if #(.drvrs(drvrs), .width(width), .bits(bits)) vif;	//maldita interface te necesito
	driver_hijo #(.drvrs(drvrs),.pgk_size(width),.depth(depth),.bits(bits)) dhijo[drvrs-1:0];
	trans_bus_mbx agnt_drv_mbx; // Mailbox del agente al driver de tipo trans_bus //AMIX ESTO ES DE LAS TRANSACCIONES/interface
	//trans_bus_mbx mntr_chckr_mbx;// Mailbox del monitor al checker de tipo trans_bus
	int espera;

	function new;
    		for (int i=0;i<drvrs; i++)begin
      			automatic int mihijo=i;
      			fork
				dhijo[mihijo]=new();
			join_none
    		end
  	endfunction

task run();
	$display("[%g] El driver fue inicializado",$time);
	forever begin
	#1
	//@(posedge vif.clk)
	    for (int i=0; i<drvrs; i++)begin
      	    automatic int mihijo=i;
	    	dhijo[mihijo].vif = vif;
	    	//dson[k].destino = transaction.destino;
	    	//dson[k].origen = transaction.origen;
	    	//dson[k].dato = transaction.D_push;
	    	//dson[k].retardo = transaction.retardo;
		    dhijo[mihijo].drvr_dhijo_mbx = agnt_drv_mbx;
		    dhijo[mihijo].origen = mihijo;//esto esta OK?
		    dhijo[mihijo].run();	
    	end		
	end
	//if(vif.push[0][transaction.origen]==1)begin	
	//espera = transaction.destino;
	//$display("[%g] D_push = %b push = %b",$time,vif.D_push[0][espera],vif.push[0][espera]);		
	//$display("Espera: %g",espera);
	//end
endtask
endclass 

