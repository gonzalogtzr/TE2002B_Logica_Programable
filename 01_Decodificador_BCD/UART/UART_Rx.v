module UART_Rx #(parameter BITS = 8, parameter CLOCK_FREQ = 50000000, parameter BAUD_RATE = 9600) (
    input wire clk,
    input wire rst,
    input wire rx_in,
    output reg [BITS-1:0] data_out,
    output reg data_valid
);
    localparam IDLE = 0, START_BIT = 1, DATA_BITS = 2, STOP_BIT = 3;
    reg [1:0] state = IDLE;
    reg [3:0] bit_index = 0;
    reg [15:0] baud_counter = 0;        

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            data_valid <= 0;
            bit_index <= 0;
            baud_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0; // Clear data valid in idle state
                    if (rx_in == 0) begin // Start bit detected (active low)
                        state <= START_BIT;
                        baud_counter <= CLOCK_FREQ / (2 * BAUD_RATE); // Sample in the middle of the bit
                    end
                end
                START_BIT: begin
                    if (baud_counter > 0) begin
                        baud_counter <= baud_counter - 1;
                    end else begin
                        baud_counter <= CLOCK_FREQ / BAUD_RATE - 1; // Reset for next bits
                        state <= DATA_BITS;
                    end
                end
                DATA_BITS: begin
                    if (baud_counter > 0) begin
                        baud_counter <= baud_counter - 1;
                    end else begin
                        baud_counter <= CLOCK_FREQ / BAUD_RATE - 1; // Reset for next bits
                        data_out[bit_index] <= rx_in; // Sample data bits LSB first
                        if (bit_index < BITS - 1) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    if (baud_counter > 0) begin
                        baud_counter <= baud_counter - 1;
                    end else begin
                        data_valid <= 1; // Data is valid after stop bit is sampled
                        state <= IDLE; // Return to idle after stop bit
                    end
                end
            endcase
        end
    end 

endmodule