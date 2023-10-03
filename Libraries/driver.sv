class fifo_sim #(parameter pkg_size=16, parameter driver=8);
     bit pop;
     bit push;
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

    task reset(bit rst);
        if(this.rst ==1) begin
           fifo.delete();
            pndng = 0;
        end     
    endtask

    task escritura(bit [pckg_sz-1:0] D_push);//push
        if (this.push==1) begin
           fifo.push_front(D_push);
            pndng = 1;
        end
    endtask

    task lectura(bit [pckg_sz-1:0] D_pop);//pop
        if (this.pop==1) begin
            D_pop = fifo.pop_back();
        end if (sim_fifo.size()==0) begin
            pndng = 0;
        end
    endtask

   
endclass

class driver_hijo #(parameter drvrs=4, parameter pkg_size=16, parameter depth=8, parameter broadcast = {8{1'b1}}); //Me vole el parametro bits
	fifo_sim #(.pkg_size(pkg_size), .depth(depth)) fifo_in;
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size), .broadcast(broadcast)) vif;	
	trans_bushandler_mbx drvr_dhijo_mbx; 
	trans_bushandler #(.pkg_size(pkg_size), .drvrs(drvrs), .broadcast(broadcast)) transaccion;	
	
	int retardo_max;
	logic [7:0]rx;//destino
	int tx; //tx  ESTO PODRIA GENERAR ERROR, ver si lo cambio a 8 bits aqui, o si mas bien cambio a entero en el bushandler INTERFACE

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
		if (tx == transaccion.dispositivo_tx; )begin 
                
			    $display("[%g] Driver: Cantidad de mensajes a enviar %g",$time,drvr_dhijo_mbx.num());
			    drvr_dhijo_mbx.get(transaccion);
			    $display(":):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):)");
			    $display("[%g] Driver_hijo: Dispositivo %g listo para enviar",$time,tx);
		
	    		vif.pndng[bits-1][tx] <= 0;
    
	    		vif.rst    <= 1;
		    	#2 vif.rst <= 0;
			    fifo_in.D_push = transaccion.D_push;//Fijarse si transacciòn tiene un tipo D_push
		    	fifo_in.escritura();
;

			    retardo = 0;
		    	while (retardo < retardo_max)begin
			    	retardo++;
		    	end
				
	
			    fifo_in.lectura();
		    	vif.D_pop[bits-1][tx] <= fifo_in.D_pop;
		    	vif.pndng[bits-1][tx] <= fifo_in.pndng;
		    	@(posedge vif.pop[0][tx]);
		    		$display("[%g] Se envio el mensaje",$time);		
		    		$display("[%g] D_pop = %b pndng = %b",$time,vif.D_pop[0][tx],vif.pndng[0][tx]);		
		end		
	endtask
endclass
class driver_papi #(parameter pkg_size=16, parameter depth=8, parameter drvrs=4,parameter broadcast={8{1'b1}}); 
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size)) vif;	
	driver_hijo #(.drvrs(drvrs),.pgk_size(pkg_size),.depth(depth),.broadcast(broadcast)) dhijo[drvrs-1:0];
	trans_bushandler_mbx agnt_drv_mbx; // Mailbox del agente al driver de tipo trans_bus

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
	    	//dson[k].tx = transaction.tx;
	    	//dson[k].dato = transaction.D_push;
	    	//dson[k].retardo = transaction.retardo;
		    dhijo[mihijo].drvr_dhijo_mbx = agnt_drv_mbx;
		    dhijo[mihijo].tx = mihijo;
            dhijo[mihijo].run();	
    	end		
	end
	//if(vif.push[0][transaction.tx]==1)begin	
	//espera = transaction.destino;
	//$display("[%g] D_push = %b push = %b",$time,vif.D_push[0][espera],vif.push[0][espera]);		
	//$display("Espera: %g",espera);
	//end
endtask
endclass 

