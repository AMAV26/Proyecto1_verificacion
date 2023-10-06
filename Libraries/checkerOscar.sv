class checker_p  #(parameter drvrs =4, parameter pckg_sz = 16);
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
 
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) emul_fifo[$];
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;
    int contador_auxiliar;

    function new();
	emul_fifo = {};
	contador_auxiliar = 0;
	to_sb = new();
	transaccion = new();

	drvr_chkr_mbx = new();
	mntr_chkr_mbx = new();
	chkr_sb_mbx = new();
    endfunction

    task update();
	$display("[%g] El Checker se esta actualizando", $time);
	forever begin
	    $display("WOAH");
	    drvr_chkr_mbx.get(transaccion);
	    $display("Transaccion recibida");
	    emul_fifo.push_front(transaccion);
	end
    endtask

    task check();
	$display("[%g] El Checker esta revisando", $time);
	forever begin
	    mntr_chkr_mbx.get(transaccion);
	    for (int i = 0; i < emul_fifo.size(); i++) begin
	        if (emul_fifo[i].dato == transaccion.dato) begin
		    to_sb.dato_enviado = emul_fifo[i].dato;
		    to_sb.tiempo_push = transaccion.tiempo;
		    to_sb.tiempo_pop = emul_fifo[i].tiempo;
		    to_sb.completado = 1;
		    to_sb.calc_latencia();
		    to_sb.print("[CHECKER]");
		    chkr_sb_mbx.put(to_sb);
	        end
	    end
	end
    endtask
endclass
