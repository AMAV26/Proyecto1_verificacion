`include "MaquinaEstado.v"
module Probador_MaquinaEstado(
    output reg CLK,
    output reg RESET,
    output reg Tarjeta_Recibida,
    output reg [15:0] PIN,
    output reg [3:0] Digito,
    output reg Digito_STB,
    output reg Tipo_Trans,
    output reg [31:0] Monto,
    output reg Monto_STB,
    input wire BALANCE,
    input wire Balance_Actualizado,
    input wire Entregar_Dinero,
    input wire Fondos_Insuficientes,
    input wire Pin_Incorrecto,
    input wire Advertencia,
    input wire Bloqueo
);

// Secuencia de pruebas
initial begin
    // Inicialización
    CLK = 0;
    RESET = 1;
    PIN = 16'h8551;
    Tarjeta_Recibida = 0; 
    Digito_STB = 0;
    Monto_STB = 0;
    Tipo_Trans = 0;
    #2 RESET = 0;

    // Caso 1: Inserción de tarjeta y Pin incorrecto una vez
    #10 Tarjeta_Recibida = 1;
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b1111; Digito_STB = 1; #2 Digito_STB = 0;
    #2;


    // Caso 2: Inserción de tarjeta y Pin incorrecto dos veces (advertencia)
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b1111; Digito_STB = 1; #2 Digito_STB = 0;
    #2;

    // Caso 3: Inserción de tarjeta y Pin incorrecto tres veces (bloqueo)
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b1111; Digito_STB = 1; #2 Digito_STB = 0;
    #10;
    #28;

    // Caso 4: Depósito exitoso con Pin correcto
    #2  RESET = 1;
    #2  RESET = 0;
    Tarjeta_Recibida = 1;
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0001; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Tipo_Trans = 1;
    #4 Monto = 32'hAAA0; Monto_STB = 1; #2 Monto_STB = 0;
    #3;
    #10;
    Tarjeta_Recibida = 0;
    #10;
    
    // Caso 5: Retiro exitoso con Pin correcto
    Tarjeta_Recibida = 1;
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0001; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Tipo_Trans = 0;
    #4 Monto = 32'h0000_0080; Monto_STB = 1; #2 Monto_STB = 0;
    #3;
    #10;
    Tarjeta_Recibida = 0;
    #10;
    

    // Caso 6: Retiro con fondos insuficientes con Pin correcto
    Tarjeta_Recibida = 1;
    #10 Digito = 4'b1000;  Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0101; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Digito = 4'b0001; Digito_STB = 1; #2 Digito_STB = 0;
    #10 Tipo_Trans = 0;
    #10 Monto = 32'hFFFF_FFFF; 
    #10 Monto_STB = 1; #2 Monto_STB = 0; 
    #3;
    #10;
    Tarjeta_Recibida = 0;
    #10;
    

    // Caso 7: Reset del sistema
    RESET = 1;
    #10 RESET = 0; Tarjeta_Recibida = 0;
    #20;
    
    // Fin del Testbench
    #50 $finish;
end


always begin
    #5 CLK = !CLK;
  end

endmodule 
