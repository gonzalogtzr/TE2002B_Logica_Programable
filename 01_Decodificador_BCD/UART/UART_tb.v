module UART_tb();

parameter ITERACIONES = 30;


//Señales para el transmisor
reg clk;
reg rst;
reg [7:0] data_in;
reg start;
//wire tx_out;
wire busy;

//Señales intermedias
wire UART_wire; // Conexión entre TX y RX

//Señales para el receptor
//reg rx_in;
wire [7:0] data_out;
wire data_valid;

UART #(.BITS(8), .CLOCK_FREQ(50000000), .BAUD_RATE(9600)) uart (
    .clk(clk),
    .rst(rst),
    //.rx_in(UART_wire), // Conecta la salida del transmisor al receptor
    .start(start),
    .busy(busy),
    .data_in(data_in),
    .data_out(data_out),
    .data_valid(data_valid)
    //.tx_out(UART_wire) // Conecta la salida del transmisor al receptor
);

initial begin
    clk = 0;
    rst = 0;
    data_in = 8'h00;
    start = 0;
end

always
    #10 clk = ~clk; // Genera un reloj de 50 MHz

initial
begin
    $display("Simulación iniciada");
    #30;
    rst = 1; // Activa el reset
    #10;        
    rst = 0; // Desactiva el reset
    #20000; // Espera suficiente tiempo para que el sistema se estabilice
    repeat(ITERACIONES) begin
        data_in = $random % 256; // Carga un dato de prueba
        start = 1; // Inicia la transmisión
        #20;
        start = 0; // Detiene la señal de inicio
        wait(!busy); // Espera a que termine la transmisión
        $display("Dato transmitido: %b, Dato recibido: %b", data_in, data_out);
        #20;
    end
    $display("Simulación finalizada");
    $finish;
end


initial begin
   $dumpfile("UART_tb.vcd");
   $dumpvars(0, UART_tb);
end

endmodule