///`include "transacciones_interface.sv"

class fifo_sim #(parameter pkg_size=16, parameter depth=8);
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

    task escritura(bit [pkg_size-1:0] D_push);//push
        if (this.push==1) begin
           fifo.push_front(D_push);
            pndng = 1;
        end
    endtask

    task lectura(bit [pkg_size-1:0] D_pop);//pop
        if (this.pop==1) begin
            D_pop = fifo.pop_back();
        end if (fifo.size()==0) begin
            pndng = 0;
        end
    endtask

   
endclass

class driver_hijo #(parameter drvrs=4, parameter pkg_size=16, parameter depth=8); //Me vole el parametro bits
	fifo_sim #(.pkg_size(pkg_size), .depth(depth)) fifo_in;
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size) ) vif;	
    trans_bushandler_mbx drvr_dhijo_mbx; 
	trans_bushandler #(.pkg_size(pkg_size))transaccion;	
	
	int retardo_max;
	logic [7:0]rx;//destino
	int tx; //tx  ESTO PODRIA GENERAR ERROR, ver si lo cambio a 8 bits aqui, o si mas bien cambio a entero en el bushandler INTERFACE

	bit [pkg_size-1:0]dato;
	bit [pkg_size-1:0]d_out;
	int retardo;
	int dest = rx;
	
	function new;
		fifo_in = new();
		drvr_dhijo_mbx = new();
		transaccion = new();
		fifo_in.pndng = 0;		
	endfunction

	task run();
	   $display("Entre al task runnn");
        drvr_dhijo_mbx.peek(transaccion);
	    $display("recibi la transaccion por medio del peek");
        transaccion.print();
        if (tx == transaccion.dispositivo_tx);begin 
                
			    $display("[%g] Driver: Cantidad de mensajes a enviar %g",$time,drvr_dhijo_mbx.num());
			    drvr_dhijo_mbx.get(transaccion);
			    $display(":):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):):)");
			    $display("[%g] Driver_hijo: Dispositivo %g listo para enviar",$time,tx);
		
	    		vif.pndng[0][tx] <= 0;
    
	    		vif.reset    <= 1;
		    	#2 vif.reset <= 0;
			    fifo_in.D_push = transaccion.D_push;
                
		    	fifo_in.escritura(fifo_in.D_push);


			    retardo = 0;
		    	while (retardo < retardo_max)begin
			    	retardo++;
		    	end
				
	
			    fifo_in.lectura(transaccion.D_pop);
		    	vif.d_pop[0][tx] <= fifo_in.D_pop;//eso esta ok?
		    	vif.pndng[0][tx] <= fifo_in.pndng;
		    	@(posedge vif.pop[0][tx]);
		    		$display("[%g] Se envio el mensaje",$time);		
		    		$display("[%g] D_pop = %b pndng = %b",$time,vif.d_pop[0][tx],vif.pndng[0][tx]);		
		end		
	endtask
endclass
class driver_papi #(parameter pkg_size=16, parameter depth=8, parameter drvrs=4); 
	virtual bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size)) vif;	
	driver_hijo #(.drvrs(drvrs),.pkg_size(pkg_size),.depth(depth)) dhijo[drvrs-1:0];
	trans_bushandler_mbx agente_driver_mbx; // Mailbox del agente al driver de tipo trans_bus
    trans_bushandler_mbx drvr_dhijo_mbx;
	int espera;
//POR QUE CREO LOS HUJOS IGUAL A LOS DRVRS PERO NO SE INICIAN LOS HPS????

function new;
    		for (int i=0;i<drvrs; i++)begin
			dhijo[i] = new();
              $display("Creando/construyendo hijo numero=%d",i); 
    		end
  	endfunction

task run();
	$display("[%g] El driver fue inicializado",$time);
	for (int i=0; i<drvrs; i++)begin
		fork
      	    		automatic int mihijo=i;
		    	begin
		            dhijo[mihijo].run();
                 $display("Ejecutando chikilin numero=%d",mihijo);    
    			end		
		join_none
	end

endtask
endclass 
