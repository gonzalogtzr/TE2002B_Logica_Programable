module cronometer (
    input  wire        MAX10_CLK1_50, // 50 MHz clock
    input  wire [3:0]  SW,            // switches
    output wire [6:0]  HEX0,          // 7-segment display
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4
);

cronometer #(.FREQ(1000)) CRONOMETRO (
    .clk(MAX10_CLK1_50),
    .rst(SW[0]),
    .start_stop(SW[1]),
    .mil_unidades(HEX0),
    .mil_decenas(HEX1),
    .seg_centenas(HEX2),
    .seg_unidades(HEX3),
    .seg_decenas(HEX4)
);