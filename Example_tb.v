module Example_tb;
reg clk, rst;
reg a, b, c, d, e;
wire f, f_clock,f_register;
// Instancia del módulo a probar
example uut (
    .clk(clk),
    .rst(rst),
    .a(a),     
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .f_clock(f_clock),
    .f_register(f_register)
);

// Generación de reloj
always #5 clk = ~clk; // Cambia el estado del reloj cada 5 unidades

initial begin
    // Inicialización de señales
    rst = 0;
    #5;
    clk = 0;
    rst = 1; // Activar reset al inicio
    a = 0; b = 0; c = 0; d = 0; e = 0;

    // Desactivar reset después de un tiempo
    #10 rst = 0;

    // Cambiar las entradas para probar diferentes combinaciones
    #10 a = 1; b = 1; c = 0; d = 0; e = 0;
    #10 a = 0; b = 0; c = 1; d = 1; e = 0;
    #10 a = 0; b = 0; c = 0; d = 0; e = 1;
    #10 a = 1; b = 1; c = 1; d = 1; e = 1;
    #10 a = 1; b = 0; c = 1; d = 0; e = 1;
    #10 a = 0; b = 1; c = 0; d = 1; e = 0;
    #10 a = 1; b = 0; c = 0; d = 1; e = 0;
    repeat (5) 
    begin
    #10; // Esperar un poco más para observar el comportamiento
        a = $random%2; b = $random%2; c = $random%2; d = $random%2; e = $random%2; // Asignar valores aleatorios a las entradas
    end

    // Finalizar la simulación después de probar las combinaciones
    #10 $finish;
end

initial begin
    $dumpfile("Example_tb.vcd"); // Archivo para guardar la simulación
    $dumpvars(0, Example_tb); // Guardar todas las variables del testbench
    $monitor("At time %t: a=%b, b=%b, c=%b, d=%b, e=%b, f=%b", $time, a, b, c, d, e, f);
end

endmodule 