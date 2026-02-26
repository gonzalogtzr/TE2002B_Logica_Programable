module clock_divider_tb();

reg clk_in, rst;
wire clk_out;
// Instancia del módulo a probar
clock_divider uut (
    .clk_in(clk_in),
    .rst(rst),
    .clk_out(clk_out)
);

// Generación de reloj
always #5 clk_in = ~clk_in; // Cambia el estado del reloj cada 5 unidades

initial begin
    // Inicialización de señales
    rst = 0;
    #5;
    clk_in = 0;
    rst = 1; // Activar reset al inicio

    // Desactivar reset después de un tiempo
    #10 rst = 0;

    // Esperar un tiempo para observar el comportamiento del reloj dividido
    #200_0_000;

    // Finalizar la simulación después de probar el módulo
    #10 $finish;
end

initial
begin
    $dumpfile("clock_divider_tb.vcd"); // Archivo para guardar la simulación
    $dumpvars(0, clock_divider_tb); // Guardar todas las variables del testbench
    //$monitor("At time %t: clk_in=%b, rst=%b, clk_out=%b", $time, clk_in, rst, clk_out);
end

endmodule
