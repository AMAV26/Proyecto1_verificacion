class scoreboard #(parameter drvrs=4, parameter pkg_size=16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx agente_scoreboard_mbx;
	test_scoreboard_mbx tst_sb_mbx;
	trans_sb #(.pkg_size(pkg_size)) transaccion_entrante;
	trans_sb scoreboard[$];     // Estructura dinamica
	trans_sb auxiliar_array[$];  // Estructura dinamica auxiliar para explorar el scoreboard
	trans_sb auxiliar_trans;
	shortreal retardo_promedio;
	shortreal bw_promedio;
	solicitud_sb orden;
	int tamano_sb = 0;
	int transacciones_completadas = 0;
	int retardo_total = 0;
	int bw_total = 0;
	
task run;
	$display("[%g] El scoreboard fue inicializado",$time);
	forever begin
		#5
		if(agente_scoreboard_mbx.num()>0)begin
			agente_scoreboard_mbx.get(transaccion_entrante);
			transaccion_entrante.print("Scoreboard: Transaccion del agente recibida");
			if(transaccion_entrante.completado)begin
				retardo_total = retardo_total + transaccion_entrante.latencia;
				bw_total = bw_total + 1/transaccion_entrante.latencia;
				transacciones_completadas++;
			end
			scoreboard.push_back(transaccion_entrante);
		end else begin 
			if(tst_sb_mbx.num()>0)begin
				case(orden)
					// Reporte completo
					rep_compl:begin
					$display("Scoreboard: Solicitud de reporte completo");
					tamano_sb=this.scoreboard.size();
					for(int i=0;i<tamano_sb;i++)begin
						auxiliar_trans=scoreboard.pop_front;
						auxiliar_trans.print("Scoreboard report:");
						auxiliar_array.push_back(auxiliar_trans);
					end
					scoreboard=auxiliar_array;
					end

					// Retardo promedio
					ret_prom:begin
					$display("Scoreboard: Solicitud de retardo promedio");
					retardo_promedio = retardo_total/transacciones_completadas;
					$display("[%g] Scoreboard: El retardo promedio es %0.3f",$time,retardo_promedio);
					end
			
					// Ancho de banda promedio
					bw_prom:begin
					$display("Scoreboard: Solicitud de ancho de banda promedio");
					bw_promedio = bw_total/transacciones_completadas;
					$display("[%g] Scoreboard: El ancho de banda promedio es %0.3f",$time,bw_promedio);
					end

					default: $display("[%g] Scoreboard: Error en solicitud");
				endcase
			end
		end
	end
endtask
endclass


