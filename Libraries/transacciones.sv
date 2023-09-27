//////////////////////////////////////////////////////////////
/////////////Posibles transacciones de la FIFO////////////////
//////////////////////////////////////////////////////////////
typedef enum {push, pop,reset} tipo_trans; 

//////////// Transacciones del bus handler (Transacciones que entran y salen de las FIFO)/////////
class trans_bushandler #(parameter pkg_size  = 16,parameter drvrs = 4,parameter broadcast={8{1'b1}});
    rand int retardo; // tiempo de retardo en ciclos de reloj que se debe esperar antes de ejecutar la transacción
  	rand bit[pkg_size-9:0] dato; // este es el dato de la transacción
  	int tiempo; //Representa el tiempo  de la simulación en el que se ejecutó la transacción 
  	tipo_trans tipo; // lectura(pop), escritura(push), reset; Podría hacerlo rand, todavia no lo haré para ver que hace
  	int max_retardo;
  	rand bit [7:0] dispositivo_tx; //fifo in (QEUE)
  	rand bit [7:0] dispositivo_rx; // fifo out (QEUE)
	bit reset;//lo hago así para controlarlo manualmente y probarlo

	function bit inside_driver_range();
    		if (dispositivo_rx >= 0 && dispositivo_rx < drvrs)
      			return 1;
    		else
      			return 0;
  	endfunction
	//esta restricción const_dispositivo_rx  asegura que la variable dispositivo_rx debe estar dentro del rango definido, en resumen solo me asegura de que el ID que randomice, vaya de cero a drvrs-1 y que si el valor no esté en ese rango tire un error
  	constraint const_retardo {retardo < max_retardo; retardo>0;} // esta restricción acota el retardo de cada transacción entre 0 y un retardo máximo definido
  
  //////Creando el constructor para inicializar los miembros de la clase //////
  	function new(int rtrd = 0, bit [pkg_size:0] dato = 0,int temp = $time,tipo_trans tipo = pop,int mx_rtrd = 10,bit [7:0] disp_tx = 0, bit [7:0] disp_rx = 0, bit rst=1);
		this.retardo = rtrd;
		this.dato = dato;
		this.tiempo = temp;
		this.tipo = tipo;
        this.reset=rst;
		this.max_retardo = mx_rtrd;
		this.dispositivo_tx = disp_tx;
		this.dispositivo_rx = disp_rx;
	endfunction
  
	function clean;
      this.retardo = 0;
      this.dato = 0;
      this.tiempo = 0;
      this.tipo = pop;
    
  	endfunction
    function void print (string tag  =  "");
      $display("[%g] [%s] Tiempo=%g Tipo=%s Retardo=%g dato = 0x%h Transmisor = 0x%h Receptor = 0x%h",
                 $time,tag,
                 this.tiempo,
                 this.tipo.name,
                 this.retardo,
                 this.dato,
                 this.dispositivo_tx,
                 this.dispositivo_rx);
    endfunction
    /*function void print(string tag = "");
    $display("[%g] %s Tiempo=%g Tipo=%s Retardo=%g dato=0x%h",$time,tag,tiempo,this.tipo,this.retardo,this.dato);
  endfunction*/
endclass

///////////PRUEBA CLASE BUS HANDLER/////////////////
module testbench;
  // Parámetros
  parameter pkg_size = 16;
  parameter drvrs = 4;
  parameter broadcast = {8{1'b1}};

  // Instancia de la clase trans_bushandler
  trans_bushandler#(pkg_size, drvrs, broadcast) transaction;
trans_bushandler#(pkg_size, drvrs, broadcast) transaction2;      
  initial begin
    // Inicializar la semilla del generador de números aleatorios
 
   
  
     
    // Crear instancias adicionales si es necesario para realizar más pruebas
    // trans_bushandler#(pkg_size, drvrs, broadcast) transaction2;

    // Asignar valores aleatorios a la instancia
    transaction = new;
    transaction2 = new(
        30, //valor para dato
        5, //valor para retardo
        $time, // tiepo actual
        push,//tipo diferente de transacciones
        10, //valor maximo retardo
        4,//valor dispositivo_tx
        4,//valor dispositivo_rx
        0//No aplico reset
    );

    // Imprimir información sobre la instancia
    transaction.print("Transacción 1");
    transaction2.print("Transaccion 2");

   
    // Ejecutar la simulación
    // ...

    // Verificar las restricciones
    assert(transaction.inside_driver_range()) else $display("Error: dispositivo_rx fuera de rango");
    assert(transaction2.inside_driver_range()) else $display("Error: dispositivo_rx fuera de rango");

    // Comprobar el restablecimiento
    transaction.clean();
    transaction2.clean();

    // Continuar con más pruebas si es necesario
    // ...

    // Finalizar la simulación
    $finish;
  end

endmodule

