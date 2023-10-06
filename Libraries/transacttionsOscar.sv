typedef enum {
    lectura,
    escritura,
    reset,
    broadcast} transaction;

typedef enum {
    retardo_promedio,
    reporte} solicitud_sb;
    


class bus_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);
    rand int retardo;
    rand bit [pckg_sz-1:0] dato;
    int tiempo;
    rand transaction tipo;
    int max_retardo;

    constraint const_retardo {retardo < max_retardo; retardo>0;}

    function new (int ret = 0, bit [pckg_sz-1:0] dto = 0, int tmp = 0, transaction tpo = escritura, int mx_rtrd = 10);
	this.retardo = ret;
	this.dato = dto;
	this.tiempo = tmp;
	this.tipo = tpo;
        this.max_retardo = mx_rtrd;
    endfunction

    function clean;
	this.retardo = 0;
        this.dato = 0;
	this.tiempo = 0;
	this.tipo = escritura;
    endfunction

    function void print(input string tag = "");
	$display("---------------------------");
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("tipo=%s", this.tipo);
        $display("retardo=%g", this.retardo);
        $display("dato=0x%h", this.dato);
        $display("---------------------------");
    endfunction

endclass


class sb_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);
    bit [pckg_sz-1:0] dato_enviado;
    int tiempo_push;
    int tiempo_pop;
    bit completado;
    bit reset;
    int latencia;

    function clean();
	this.dato_enviado = 0;

	this.tiempo_push = 0;
	this.tiempo_pop = 0;
	this.completado = 0;
	this.latencia = 0;
    endfunction

    task calc_latencia;
	this.latencia = this.tiempo_push - this.tiempo_pop;
    endtask

    function void print(input string tag = "");
	$display("---------------------------");
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("Dato enviado=%h", this.dato_enviado);
        $display("tiempo push=%g", this.tiempo_push);
        $display("tiempo pop=%g", this.tiempo_pop);
	$display("latencia=%g", this.latencia);
        $display("---------------------------");
    endfunction

endclass


interface bus_if #(parameter bits = 1,parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) 
    (
        input clk
    );
    
    logic reset;
    logic pndng[bits-1:0][drvrs-1:0];
    logic push[bits-1:0][drvrs-1:0];
    logic pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
endinterface

typedef mailbox #(bus_pckg #(.drvrs(4), .pckg_sz(16))) bus_pckg_mbx;
typedef mailbox #(sb_pckg#(.drvrs(4), .pckg_sz(16))) sb_pckg_mbx; 
