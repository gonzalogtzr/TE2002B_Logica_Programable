module example(

    input clk,rst,
    input a,b,c,d,e,
    output reg f,f_clock,f_register
);

always @(*) //Cualquier cambio en las entradas a,b,c,d,e hará que se ejecute el bloque de código
begin
    f = (a & b) | (c & d) | e;
end

always @(posedge clk or posedge rst) //En cada flanco de subida del reloj o cuando se active el reset
begin
    if(rst) //Si el reset está activo
        f_clock <= 0; //Poner f a 0
    else
        f_clock <= (a & b) | (c & d) | e; //Sino, actualizar f con la nueva combinación de entradas
        f_register <= f_clock; //Actualizar el registro con el valor de f_clock
end

endmodule