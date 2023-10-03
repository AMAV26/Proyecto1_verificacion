class monitor_hijo #(parameter drvrs=4, parameter pkg_size=16, parameter depth=8 ,parameter broadcast={8{1'b1}});//añadp broadcast=??
	fifo_sim #(.pkg_size(pkg_size), .depth(depth)) fifo_out;
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size) ) vif;	
	trans_bushandler #(.pkg_size(pkg_size), .drvrs(drvrs), .broadcast(broadcast)) transaccion;	 //ver como sale en el interface
	
	logic [7:0]rx; //destino
	int tx;//origen
	bit [pkg_size-1:0]dato;
	bit [pkg_size-1:0]d_out; //estos estan oK?
	int retardo;
	int listo;
	
	function new;
		fifo_out = new();
		fifo_out.pndng <= 0;
		dato = 0;
		d_out = 1;		
	endfunction
	
	task run();
	dato = vif.D_push[bits-1][tx];
	rx = dato[pkg_size-1:pkg_size-8];
	if (rx == tx && vif.push[bits-1][tx] == 1)begin
		$display("[%g] Mhijo inicializado",$time);
		$display("Destino = %g",rx);
		$display("Dato = %b",dato);
		$display("--------------------------------------------------------------");
		$display("[%g] Monitor_hijo: Dispositivo %g listo para recibir",$time,tx);
		fifo_out.D_push=vif.D_push[bits-1][tx];
		fifo_out.push(); 
		fifo_out.pop();
		/*transaction.D_pop = fifo_out.D_pop;
		transaction.tiempo = $time;*/
		vif.pndng[0][tx] <= fifo_out.pndng;
		$display("[%g] Se recibio el mensaje",$time);		
		$display("[%g] D_pop = %b",$time,fifo_out.D_pop);
	end
	endtask
endclass

class monitor_papi #(parameter pkg_size=16, parameter depth=8, parameter drvrs=4, parameter broadcast={8{1'b1}}); 
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size)) vif;	
	monitor_hijo #(.drvrs(drvrs),.pkg_size(pkg_size),.depth(depth),.broadcast(broadcast)) mhijo[drvrs-1:0];
	//trans_bus_mbx mntr_chckr_mbx;// Mailbox del monitor al checker de tipo trans_bus
	trans_bushandler #(.pkg_size(pkg_size), .drvrs(drvrs), .broadcast(broadcast)) transaccion; 	//ver como lo llame en la interface

	function new;
    		for (int i=0;i<drvrs; i++)begin
      			automatic int newmon=i;
      			fork
				mhijo[newmon]=new();
			join_none
    		end
  	endfunction

task run();
	$display("[%g] El monitor fue inicializado",$time);
	forever begin
	#1
	//@(posedge vif.clk)
	for (int i=0; i<drvrs; i++)begin
        automatic int newmon=i;
		mhijo[newmon].vif = vif;
		//mson[k].drv_dson_mbx = agnt_drv_mbx;
		mhijo[newmon].origen = newmon;
		mhijo[newmon].run();	
	end		
	end
	//if(vif.push[0][transaction.origen]==1)begin	
	//espera = transaction.destino;
	//$display("[%g] D_push = %b push = %b",$time,vif.D_push[0][espera],vif.push[0][espera]);		
	//$display("Espera: %g",espera);
	//end
endtask
endclass 

