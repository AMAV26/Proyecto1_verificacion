//`include "MaquinaEstado.v"
`include "probador_tarea3.v"

module testbench_atm_controller; 
    wire CLK;
    wire RESET;
    wire Tarjeta_Recibida;
    wire Tipo_Trans;
    wire Digito_STB;
    wire [3:0] Digito;
    wire [15:0] PIN;
    wire Monto_STB;
    wire [31:0]Monto;
    wire [63:0] BALANCE;
    wire Balance_Actualizado;
    wire Entregar_Dinero; 
    wire Pin_Incorrecto; 
    wire Advertencia;
    wire Bloqueo;
    wire Fondos_Insuficientes;

    // Visualización de señales de salida en la forma de onda
  
  initial begin
        $dumpfile("resultados_Tarea3.vcd");
        $dumpvars(-1, cajero);
        $monitor("%b",BALANCE, Balance_Actualizado, Entregar_Dinero, Pin_Incorrecto, Advertencia, Bloqueo, Fondos_Insuficientes );
    end

  MaquinaEstado cajero(
    .CLK(CLK),
    .RESET(RESET),
    .Tarjeta_Recibida(Tarjeta_Recibida),
    .Digito(Digito),
    .Digito_STB(Digito_STB),
    .Tipo_Trans(Tipo_Trans),
    .Monto(Monto),
    .Monto_STB(Monto_STB),
    .PIN(PIN),
    .BALANCE(BALANCE),
    .Balance_Actualizado(Balance_Actualizado),
    .Entregar_Dinero(Entregar_Dinero),
    .Pin_Incorrecto(Pin_Incorrecto),
    .Advertencia(Advertencia),
    .Bloqueo(Bloqueo),
    .Fondos_Insuficientes(Fondos_Insuficientes)
 );

Probador_MaquinaEstado PO(
    .CLK(CLK),
    .RESET(RESET),
    .Tarjeta_Recibida(Tarjeta_Recibida),
    .Digito(Digito),
    .Digito_STB(Digito_STB),
    .Tipo_Trans(Tipo_Trans),
    .Monto(Monto),
    .Monto_STB(Monto_STB),
    .PIN(PIN),
    .BALANCE(BALANCE),
    .Balance_Actualizado(Balance_Actualizado),
    .Entregar_Dinero(Entregar_Dinero),
    .Pin_Incorrecto(Pin_Incorrecto),
    .Advertencia(Advertencia),
    .Bloqueo(Bloqueo),
    .Fondos_Insuficientes(Fondos_Insuficientes)
);

endmodule 
