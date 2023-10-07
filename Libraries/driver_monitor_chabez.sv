class driver #(parameter pckg_sz = 16,parameter drvrs = 4);
	virtual bushandler_if #(.pckg_sz(pckg_sz),.drvrs(drvrs)) vif;
	trans_bushandler_mbx agent_drvr_mbx;
	trans_bushandler #(.pkg_size(pkg_size)) transaccion_entrante;
	int espera;
	
  
  	bit [pckg_sz-1:0] D_out[drvrs][$:0]; //FIFOS emuladas 
	

	task run();
		$display("[%g] El driver fue inicializado",$time);
        foreach(vif.pop[0][i]) begin
  			fork
  				forever @(posedge vif.clk) begin
  			 		if (vif.pop[0][i]) begin
  			 			D_out[i].pop_front;
  			 		end
  			 	end
  			join_none
  		end //Hago pop de todo

        @(posedge vif.clk);
		forever begin
			transaccion_entrante=new;
			vif.reset = 0;

			foreach(vif.pndng[i]) begin
				foreach(vif.pndng[i][j]) begin
					vif.pndng[i][j]=0;
					vif.D_pop[i][j]=0;
				end //Reinicio todas las fifos y los pendings
			end

           espera  =  0;
           @(posedge vif.clk); 
           agent_drvr_mbx.get(transacccion_entrante);
           while(retardo < transaccion_entrante.retardo)begin
        		@(posedge vif.clk);
          			retardo =  retardo+1;
			end //Aguanto la transaccion espera por retardo
            D_out[transaction.tx_device].push_back(transaccion_entrante.dato); //
            vif.D_pop[0][transaction.tx_device]=D_out[transaccion_entrante.dispositivo_tx][0];
			vif.pndng[0][transaction.tx_device]=1;
			$time;
			transaction.print("Driver: Transaccion ejecutada");
			



