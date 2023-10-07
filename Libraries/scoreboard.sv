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
	shortreal bw_total = 0;
    int bw_1000;
    string linea_csv, d_enviado,s_tx,s_rx,s_tp;  	
task run;
    $system("echo dato,transmisor,receptor,tipo,t_pop,t_push > scoreboard.csv");	
    $display("[%g] El scoreboard fue inicializado",$time);
	TiempoScoreboard: forever begin//Inicializo el forever, con la condicion de que si se llega a 500, se termina
	    #5 //Le doy tiempo al scoreboard de que hayan transacciones  	
		if(checker_scoreboard_mbx.num()>0)begin
			checker_scoreboard_mbx.get(transaccion_entrante);
            transaccion_entrante.tiempo_pop=$time;
            transaccion_entrante.calc_latencia();//Calculo la latencia, con el t_pop siendo el momento en que una transaccion llega, y el t_push, el momento en que la transaccion sale del agente
			bw_1000=(4000/transaccion_entrante.latencia);
			
            retardo_total = retardo_total + transaccion_entrante.latencia;//Sumo al retardo total 

			bw_total = bw_total + bw_1000; //Sumo al ancho de banda total
			transacciones_completadas++;
			scoreboard.push_back(transaccion_entrante);//Meto la transaccion a la fila del scoreboard
		end else begin // Cuando no hay nada en la cola de transacciones
			if(tst_sb_mbx.num()>0)begin
				tst_sb_mbx.get(orden);
                case(orden)
				    // Retardo promedio
					retardo_promedio: begin //Pido el retardo promedio y como estoy tratando esto al final, de un solo mando el bw promedio
					$display("Solicitud de retardo promedio");
					retardo_promedio = retardo_total/transacciones_completadas;//El retardo promedio es el retardo total entre el numero de transacciones
					$display("[%g] Scoreboard: El retardo promedio es %0.3f",$time,retardo_promedio);
				    $display("Scoreboard: Solicitud de ancho de banda promedio");
                    bw_promedio = bw_total/(1000*transacciones_completadas);//El mil se debe a que estaba haciendo esto mas bw1000, pero eso es porque estaba usando ints y no shortreal, ahora cambiarlo en realidad no afecta nada, y se ve ddivertido
					$display("[%g] Scoreboard: El ancho de banda promedio es %0.3f bits por segundo",$time,bw_promedio);
						
                end
			
					//Ancho de banda promedio
					bw_promedio:begin
					$display("Scoreboard: Solicitud de ancho de banda promedio");
					$display(bw_total);
                    bw_promedio = bw_total/transacciones_completadas;
					$display("[%g] Scoreboard: El ancho de banda promedio es %0.3f",$time,bw_promedio);
					end

				endcase
			end
		end
        if ($time > 100000) begin
            disable TiempoScoreboard; //Cuando llega a 700, lo apago

        end
	end
    $display("Simulacion finalizada, imprimiendo transacciones presentes en el scoreboard");
    foreach (scoreboard[i]) begin//Para cada dato en el scoreboard, lo imprimo en el csv respectivo
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


