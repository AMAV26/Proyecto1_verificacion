class fifo_sim #(parameter pkg_size=16, parameter drvrs=8);
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


class driver #(parameter pkg_size = 16,parameter drvrs = 4);
    fifo_sim #(.pkg_size(pkg_size), .drvrs(drvrs)) fifo_in;
    virtual bushandler_if #(.pkg_size(pkg_size),.drvrs(drvrs)) vif;
	trans_bushandler_mbx agente_driver_mbx;
	//trans_bushandler_mbx driver_chkr_mbx;  //Esto puede que lo necesite
    //hacer mas bien en el monitor
	int retardo;//tiempo de espera
	
  
  	//bit [pkg_size-1:0] D_out[drvrs][$:0]; //FIFOS emuladas, si todo sale
    //bien ELIMINAR
	trans_bushandler #(.pkg_size(pkg_size),.drvrs(drvrs)) transaccion;


	task run();
		$display("[%g] El driver fue inicializado",$time);

		foreach(vif.pop[0][i]) begin
  			fork
  				forever @(posedge vif.clk) begin
  			 		if (vif.pop[0][i]) begin
  			 			fifo_in[i].pop_front;
  			 		end
  			 	end
  			join_none
  		end

		@(posedge vif.clk);
		vif.reset = 1;
		@(posedge vif.clk);
		forever begin
			vif.reset = 0;

			foreach(vif.pndng[i]) begin
				foreach(vif.pndng[i][j]) begin
					vif.pndng[i][j]=0;
					vif.d_pop[i][j]=0;
				end 
			end

      		$display("[%g] el Driver está esperando por una transacción",$time);				
      		retardo  =  0;
      		@(posedge vif.clk);
      		agente_driver_mbx.get(transaccion);
      		transaccion.print("Driver: Transaccion recibida");
      		$display("Transacciones pendientes en el mbx agnt_drv  =  %g",agente_driver_mbx.num());

      		while(retardo < transaccion.retardo)begin
        		@(posedge vif.clk);
          			retardo  =  retardo+1;
			end

			case(transaccion.tipo)
				Escritura:begin
                  foreach (fifo_in[0][i]) begin	
                    	fifo_in.escritura(transaccion.dato);
						vif.d_pop[0][i]=fifo_in.D_pop;
						vif.pndng[0][i]=1;
					end 
					transaccion.tiempo  =  $time;
				//	driver_chkr_mbx.put(transaction);//creo que esto lo hace
                //	chaves desde el agente es enviar el mbx del agente
                //	a scoreboard con la transaccion
                  transaction.print("Driver: Transaccion broad ejecutada");
				end

				lectura:begin
                  	fifo_in[transaccion.dispositivo_tx].push_back(transaccion.dato); //Agregamos el dato enviado en la fifo out del tx_device
                  	vif.d_pop[0][transaccion.dispositivo_tx]=fifo_in[transaccion.dispositivo_tx][0];
					vif.pndng[0][transaccion.dispositivo_tx]=1;
					transaccion.tiempo  =  $time;
				//	driver_chkr_mbx.put(transaction);
	     			transaction.print("Driver: Transaccion ejecutada");
				end

				reset:begin
					vif.reset = 1;
					transaccion.tiempo  =  $time;
					//driver_chkr_mbx.put(transaccion);
					transaccion.print("Driver: Transaccion ejecutada");
				end

				default:begin
					$display("[%g] Driver Error: la transacción recibida no tiene tipo valido",$time);
	   	 			$finish;
				end
			endcase 
			@(posedge vif.clk);
		end
	endtask
endclass
