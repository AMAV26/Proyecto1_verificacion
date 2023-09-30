//////////////////////////////////////////////////////////////
/////////////Posibles transacciones de la FIFO////////////////
//////////////////////////////////////////////////////////////
typedef enum {push, pop,reset} tipo_trans; 
///////////////////////////////////////////////////////////////////////////
//////////////// Transacciones del bus handler/////////////////////////////////////// (Transacciones que entran y salen de las FIFO)////////////////////////////////////////////////////////////////////////////////////////////////
class trans_bushandler #(parameter pkg_size  = 16,parameter drvrs = 4,parameter broadcast={8{1'b1}});
    rand int retardo; // tiempo de retardo en ciclos de reloj que se debe esperar antes de ejecutar la transacción
  	rand bit[pkg_size-9:0] dato; // este es el dato de la transacción  
    //Estamos manejando bien el dato? 
  	int tiempo; //Representa el tiempo  de la simulación en el que se ejecutó la transacción 
  	tipo_trans tipo; // lectura(pop), escritura(push), reset; Podría hacerlo rand, todavia no lo haré para ver que hace
  	int max_retardo;
  	rand bit [7:0] dispositivo_tx; //fifo in (QUEUE)
  	rand bit [7:0] dispositivo_rx; // fifo out (QUEUE)
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
  function void randomize_data();
    this.dato=$random;
    this.dato=this.dato & ((1<<(pkg_size - 9))-1); //Restringe el tamaño del valor al tamaño adecuado

    
  endfunction
  
  function void randomize_drivers();
    this.dispositivo_rx=$random; 
    this.dispositivo_tx=$random;
    
  

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
trans_bushandler#(pkg_size, drvrs, broadcast) transaction3;
  initial begin
    // Inicializar la semilla del generador de números aleatorios
 
   
  
     
    // Crear instancias adicionales si es necesario para realizar más pruebas
    // trans_bushandler#(pkg_size, drvrs, broadcast) transaction2;

    // Asignar valores aleatorios a la instancia
    transaction = new;
    transaction2 = new(
        30, //valor para dato
        5, //valor para retardo
        $time, // tiempo actual
        push,//tipo diferente de transacciones
        10, //valor maximo retardo
        2,//valor dispositivo_tx, si pongo valor mayor o igual a 4, el assert se dispara, pero como quiero probar la funcion clean, voy a setear un valor menor a 4 
        2,//valor dispositivo_rx
        0//No aplico reset
    );
    transaction2.randomize_data(); 
    transaction2.randomize_drivers();
  /*  transaction3 = new(
       $urandom_range(1,255), //valor random  para dato
         $urandom_range(1,75), //valor random para retardo
         $time, // tiempo actual
          push,//tipo diferente de transacciones
         50, //valor maximo retardo
          $urandom_range(1,3),//valor random dispositivo_tx
          $urandom_range(1,3),//valor random  dispositivo_rx
          1// aplico reset
      );*/

    // Imprimir información sobre la instancia
    transaction.print("Transacción 1");
    transaction2.print("Transaccion 2");
   // transaction3.print("Transaccion 3");
   
    // Ejecutar la simulación
    // ...

    // Verificar las restricciones
    assert(transaction.inside_driver_range()) else $display("Error: dispositivo_rx fuera de rango");
    assert(transaction2.inside_driver_range()) else $display("Error: dispositivo_rx fuera de rango");
  // assert(transaction3.inside_driver_range()) else $display("Error: disposi    tivo_rx fuera de rango");
    //reestablecer valores a algo conocido
     transaction.clean();
     transaction2.clean();
    // transaction3.clean();

    // Comprobar el restablecimiento
    transaction2.print("valores en cero, transaccion2:");
   // transaction3.print("valores en cero, transaccion3:");

    // Continuar con más pruebas si es necesario
    // ...

    // Finalizar la simulación
 //   $finish;
  end
endmodule
  /////////////////FINAL DE LA PRUEBA DE LA CLASE BUS HANDLER///////////
  

 ///////////////////////////////////////////////////////////////////
 ///////Creando la Interface que se conecta con la FIFO (DUT)///////
 ///////////////////////////////////////////////////////////////////
 
interface bushandler_if #( parameter drvrs = 4, parameter pkg_size = 16)//no defino el parametro bits por que es 1 siempre.
(
  input clk  
);
logic reset;
logic pndng[0:0][drvrs-1:0];
logic push[0:0][drvrs-1:0];
logic pop[0:0][drvrs-1:0];
logic [pkg_size-1:0] d_pop [0:0][drvrs-1:0];
logic [pkg_size-1:0] d_push [0:0][drvrs-1:0];
 
endinterface

//////////////////Probando que la interface funcione//////////////////
module testbench2;
    reg clk;
    //instanciando bushandler
    bushandler_if #(4,16) my_bushandler( .clk(clk) );
    
    //generar reloj
    always begin
        #10 clk = !clk;
    end
    initial begin
        clk = 0; //inicializo el reloj
        #5 
        $display("[%g]Entre al dummy test de la interface yeiiii:",$time     );

        my_bushandler.d_push[0][0] = 8'hAA;//le asigno un valor a d_push
        my_bushandler.push[0][0] = 1; //hago el pusheo
        #5
        my_bushandler.d_pop[0][0] = 8'hBB;
        my_bushandler.pop[0][0] = 1;
        #100
        $display("Datos despues de hacer push: %h",my_bushandler.d_pop[0][0] );
        $display("Datos despues de hacer pop: %h",my_bushandler.d_push[0][0]     );       
        $finish;
    end

endmodule
///////Segun el dummy test la interfaz funca///////////

////////////////////////////////////////////////////
// Objeto de transacción usado en el scoreboard  //
////////////////////////////////////////////////////

class trans_sb #(parameter pkg_size=16);
  bit [pkg_size-1:0] dato_enviado;  //con todo y ID
  int tiempo_push;
  int tiempo_pop;
  bit completado;
  bit overflow;
  bit underflow;
  bit reset;
  int latencia;
  
  function clean();
    this.dato_enviado = 0;
    this.tiempo_push = 0;
    this.tiempo_pop = 0;
    this.completado = 0;
    this.overflow = 0;
    this.underflow = 0;
    this.reset = 0;
    this.latencia = 0;
  endfunction

  task calc_latencia;
    this.latencia = this.tiempo_pop - this.tiempo_push;
  endtask
  
  function print (string tag);
    $display("[%g] %s dato=%h,t_push=%g,t_pop=%g,cmplt=%g,ovrflw=%g,undrflw=%g,rst=%g,ltncy=%g", 
             $time,
             tag, 
             this.dato_enviado, 
             this.tiempo_push,
             this.tiempo_pop,
             this.completado,
             this.overflow,
             this.underflow,
             this.reset,
             this.latencia);
  endfunction
endclass
/////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el scoreboard //
/////////////////////////////////////////////////////////////////////////
typedef enum {retardo_promedio,reporte} solicitud_sb;

/////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el agente      //
/////////////////////////////////////////////////////////////////////////
typedef enum {llenado_aleatorio,trans_aleatoria,trans_especifica,sec_trans_aleatorias} instrucciones_agente;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(trans_fifo) trans_fifo_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(trans_sb) trans_sb_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(solicitud_sb) comando_test_sb_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(instrucciones_agente) comando_test_agent_mbx;

typedef mailbox
///////Lo anterior no tiene dummy test, ya que es còdigo del profe que según él ya está probado/////
