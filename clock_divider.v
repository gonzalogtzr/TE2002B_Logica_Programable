module clock_divider(
    input clk_in, // Reloj de entrada
    input rst,    // Señal de reset
    output reg clk_out // Reloj de salida dividido
);
reg [10:0] count; // Contador de 2 bits para dividir el reloj por 4

always @(posedge clk_in or posedge rst) begin
    if (rst) begin
        count <= 0; // Reiniciar el contador al activar el reset
        clk_out <= 0; // Reiniciar el reloj de salida al activar el reset
    end else begin
        count <= count + 1; // Incrementar el contador en cada flanco de subida del reloj de entrada
        if (count == 11'b11111111111) begin // Cuando el contador llega a 2047 (división por 2048)
            clk_out <= ~clk_out; // Cambiar el estado del reloj de salida
            count <= 0; // Reiniciar el contador
        end
    end
end
endmodule