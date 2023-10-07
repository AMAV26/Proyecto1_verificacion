class monitor #(parameter pkg_size = 16,parameter drvrs = 4, parameter brodcst={8{1'b1}});
  virtual bushandler_if #(.pkg_size(pkg_size),.drvrs(drvrs)) vif;
  trans_bushandler_mbx monitor_checker_mbx;
  trans_bushandler #(.pkg_size(pkg_size)) transaccion_saliente;
  bit [pkg_size-1:0] D_in [drvrs][$]; 
  

  task run();
   $display("[%g] El monitor fue inicializado",$time);
    #1    
    tiempo_monitor: forever begin
      transaccion_saliente = new;

        
        
      for (int i=0; i<drvrs;i++) begin 
        $display("1");
        vif.push[0][i]=1;
          if (vif.push[0][i]) begin
             D_in[i].push_back(vif.d_push[0][i]);
             $display("[%g] Operación completada",$time);
             transaccion_saliente.dato = D_in[i].pop_front;
             monitor_checker_mbx.put(transaccion_saliente);
             transaccion_saliente.print("Monitor: Transaccion enviada al checker"); 
    end
end

if ($time>100000) begin
    disable tiempo_monitor;
end
end
  endtask
endclass
