module UART #(parameter BITS = 8, parameter CLOCK_FREQ = 50000000, parameter BAUD_RATE = 9600) (
    input wire clk,
    input wire rst,
    //input wire rx_in,
    input wire start,
    input wire [BITS-1:0] data_in,
    output wire [BITS-1:0] data_out,
    output wire data_valid,
    //output wire tx_out,
    output wire busy
);

wire UART_wire; // Conexión entre TX y RX

    UART_Tx #(.BAUD_RATE(BAUD_RATE), .CLOCK_FREQ(CLOCK_FREQ), .BITS(BITS)) uart_tx (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .start(start),
        .tx_out(UART_wire),
        .busy(busy)
    );

    UART_Rx #(.BITS(BITS), .CLOCK_FREQ(CLOCK_FREQ), .BAUD_RATE(BAUD_RATE)) uart_rx (
        .clk(clk),
        .rst(rst),
        .rx_in(UART_wire),
        .data_out(data_out),
        .data_valid(data_valid)
    );
endmodule