class scoreboard #(parameter pkg_size=16, parameter drvrs=4, parameter broadcast = {8{1'b1}});
	trans_sb_mbx checker_scoreboard_mbx;
	comando_test_sb_mbx tst_sb_mbx;
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
    string linea_csv, d_enviado,s_tx,s_rx,s_tp;  	
task run;
    $system("echo dato,transmisor,receptor,tipo,t_pop,t_push > scoreboard.csv");	
    $display("[%g] El scoreboard fue inicializado",$time);
	TiempoScoreboard: forever begin
		#5
		if(checker_scoreboard_mbx.num()>0)begin
			checker_scoreboard_mbx.get(transaccion_entrante);
            transaccion_entrante.tiempo_pop=$time;
            transaccion_entrante.calc_latencia();
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
					reporte: begin
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
					retardo_promedio: begin
					$display("Scoreboard: Solicitud de retardo promedio");
					retardo_promedio = retardo_total/transacciones_completadas;
					$display("[%g] Scoreboard: El retardo promedio es %0.3f",$time,retardo_promedio);
					end
			
					// Ancho de banda promedio
					/*bw_prom:begin
					$display("Scoreboard: Solicitud de ancho de banda promedio");
					bw_promedio = bw_total/transacciones_completadas;
					$display("[%g] Scoreboard: El ancho de banda promedio es %0.3f",$time,bw_promedio);
					end*/

					default: $display("[%g] Scoreboard: Error en solicitud", $time);
				endcase
			end
		end
        if ($time > 500) begin
            disable TiempoScoreboard;
        end
	end
    $display("Simulacion finalizada, imprimiendo transacciones presentes en el scoreboard");
    foreach (scoreboard[i]) begin
        scoreboard[i].print("");
        d_enviado.hextoa(scoreboard[i].dato_enviado);
        s_rx.hextoa(scoreboard[i].drvr_rx);
        s_tx.hextoa(scoreboard[i].drvr_tx);
        s_tp.hextoa(scoreboard[i].tipo_transaccion);
        linea_csv= {d_enviado,",",s_tx,",",s_rx,",",s_tp};
        $system($sformatf("echo %0s >> scoreboard.csv", linea_csv));


    end
endtask
endclass


