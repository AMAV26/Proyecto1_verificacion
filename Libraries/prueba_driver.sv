`timescale 1ns/10ps
`include "transacciones_interface.sv"
`include "driver.sv"
`include "Library.sv"
`include "agente.sv"


module bushandler_tb;
///creando mbx 
comando_test_agente_mbx test_agente_mb;
 trans_sb_mbx test_scoreboard_mb;
 trans_bushandler_mbx agente_driver_mb;
 trans_bushandler_mbx dhijo_mbx;
 //creando tipo de instruccion
instrucciones_agente tipo_instruccion=llenado_aleatorio;
//creando/instanciando driver 
reg reset_tb,clk_tb;
reg pndng_tb [0:0][3:0];
reg [15:0] D_pop_tb [0:0][3:0];
wire push_tb [0:0][3:0];
wire pop_tb [0:0][3:0];
wire [15:0] D_push_tb [0:0][3:0];
parameter drvrs = 4;
parameter pkg_size = 16;
parameter depth = 16;
    reg clk_tb;
  driver_papi#(.drvrs(drvrs),.pkg_size(pkg_size)) drivertb;
  bushandler_if #(.drvrs(drvrs), .pkg_size(pkg_size)) vif(.clk(clk_tb));
 
  
  bs_gnrtr_n_rbtr DUT_0 (.clk(clk_tb),
                         .reset(reset_tb),
                         .pndng(vif.pndng),
                         .push(vif.push),
                         .pop(vif.pop),
                         .D_pop(vif.d_pop),
                         .D_push(vif.d_push)
                        );

  agente #(pkg_size,drvrs) agente_tb;
         instrucciones_agente tipo_instruccion = llenado_aleatorio;
initial begin
        clk_tb=0;
         test_agente_mb=new();
         test_scoreboard_mb=new();
         agente_driver_mb=new();
         agente_tb=new();
         drivertb=new();

         drivertb.vif = vif;
 //poniendo mbx en el agente
         test_agente_mb.put(tipo_instruccion);
         agente_tb.test_agente_mbx= test_agente_mb;
         agente_tb.agente_scoreboard_mbx = test_scoreboard_mb;
         agente_tb.agente_driver_mbx=agente_driver_mb;
         drivertb.agente_driver_mbx = agente_driver_mb;
         agente_tb.InitandRun();
         drivertb.run();
         
    end
endmodule
