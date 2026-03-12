module cronometer #(parameter FREQ = 1000)(

    input clk, rst,
    input start_stop,

    output [6:0] mil_unidades,
    output [6:0] mil_decenas,
    output [6:0] seg_centenas,
    output [6:0] seg_unidades,
    output [6:0] seg_decenas

);

wire clk_div;

clock_divider #(.FREQ(FREQ)) DIVISOR_REFRESH 
(
.clk(clk),
.rst(rst),
.clk_div(clk_div)
);  

reg [9:0] mil,seg;

always @(posedge clk_div) begin
    if (rst) begin
        mil <= 0;
        seg <= 0;
    end 
    else 
    if (start_stop) 
    begin
        if (mil == 999) 
        begin
            mil <= 0;
            if (seg == 59) 
            begin
                seg <= 0;
            end 
            else 
            begin
                seg <= seg + 1;
            end
        end 
        else 
        begin
            mil <= mil + 1;
        end
    end
    else
    begin
        seg <= seg;
        mil <= mil;
    end

bcd #(.N(10)) BCD_SEGUNDOS (
    .binary(seg),
    .disp_uni(mil_unidades),
    .disp_dec(mil_decenas)
    //.disp_cen(seg_centenas)
    //.disp_mil(seg_unidades)
);

bcd #(.N(10)) BCD_MILISEGUNDOS (
    .binary(mil),
    .disp_uni(seg_unidades),
    .disp_dec(seg_decenas)
    //.disp_cen(seg_centenas)
    //.disp_mil(seg_unidades)
);



endmodule