class driver #(parameter pkg_size = 16,parameter drvrs = 4);
	virtual bushandler_if #(.pkg_size(pkg_size),.drvrs(drvrs)) vif;
	trans_bushandler_mbx agente_driver_mbx;
	trans_bushandler #(.pkg_size(pkg_size)) transaccion_entrante;
	int retardo;
	
  
  	bit [pkg_size-1:0] D_out[drvrs][$]; //FIFOS emuladas 
	

	task run();
        transaccion_entrante=new();
		$display("[%g] El driver fue inicializado",$time);
         foreach(vif.pop[0][i]) begin
  			fork
  			tiempo_pops:	forever begin
  		         #1000	
                if (vif.pop[0][i]) begin
                    $display ("Hols asdasdasdda");
  			 			D_out[i].pop_front;
  			 		end
                    if ($time>100000) begin
                    disable tiempo_pops;
                    end 
  			 	end
  			join_none
  		end //Hago pop de todo

	tiempo_driver:	forever begin
            #1
			transaccion_entrante=new;
			vif.reset = 0;
			/*foreach(vif.pndng[i]) begin
				foreach(vif.pndng[i][j]) begin
					vif.pndng[i][j]=0;
					vif.d_pop[i][j]=0;
				end //Reinicio todas las fifos y los pendings
			end*/

           retardo  =  0;
           agente_driver_mbx.get(transaccion_entrante);
           D_out[transaccion_entrante.dispositivo_tx].push_back(transaccion_entrante.dato); //
           vif.d_pop[0][transaccion_entrante.dispositivo_tx]=D_out[transaccion_entrante.dispositivo_tx][0];
           vif.pndng[0][transaccion_entrante.dispositivo_tx]=1;
    	   $display($time);		
            
           if ($time>100000) begin
                disable tiempo_driver;
            end
            end
        
        endtask
  endclass
