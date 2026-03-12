module VGA_chess (
    input wire MAX10_CLK1_50, // Reloj base de 50 MHz de la placa
    output wire [3:0] VGA_R,  // 4 pines para Rojo
    output wire [3:0] VGA_G,  // 4 pines para Verde
    output wire [3:0] VGA_B,  // 4 pines para Azul
    output wire VGA_HS,       // Sincronización Horizontal
    output wire VGA_VS        // Sincronización Vertical
);

    // --------------------------------------------------------
    // 1. Divisor de Reloj: de 50 MHz a 25 MHz
    // --------------------------------------------------------
    reg clk_25 = 0;
    always @(posedge MAX10_CLK1_50) begin
        clk_25 <= ~clk_25;
    end

    // --------------------------------------------------------
    // 2. Parámetros VGA (640x480 @ 60Hz)
    // --------------------------------------------------------
    // Horizontal
    localparam H_SYNC  = 96;
    localparam H_BACK  = 48;
    localparam H_DISP  = 640;
    localparam H_FRONT = 16;
    localparam H_TOTAL = 800;

    // Vertical
    localparam V_SYNC  = 2;
    localparam V_BACK  = 33;
    localparam V_DISP  = 480;
    localparam V_FRONT = 10;
    localparam V_TOTAL = 525;

    // --------------------------------------------------------
    // 3. Contadores de Píxeles
    // --------------------------------------------------------
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    // Señales de sincronización (Activas en bajo)
    assign VGA_HS = (h_count < H_SYNC) ? 1'b0 : 1'b1;
    assign VGA_VS = (v_count < V_SYNC) ? 1'b0 : 1'b1;

    // --------------------------------------------------------
    // 4. Lógica de Dibujo (Área visible)
    // --------------------------------------------------------
    wire active_video = (h_count >= (H_SYNC + H_BACK)) && 
                        (h_count < (H_TOTAL - H_FRONT)) &&
                        (v_count >= (V_SYNC + V_BACK)) && 
                        (v_count < (V_TOTAL - V_FRONT));

    // Coordenadas relativas a la pantalla (0 a 639 en X, 0 a 479 en Y)
    wire [9:0] x = h_count - (H_SYNC + H_BACK);
    wire [9:0] y = v_count - (V_SYNC + V_BACK);

    // --------------------------------------------------------
    // 5. Patrón de Tablero de Ajedrez
    // --------------------------------------------------------
    // Un tablero clásico tiene 8x8 casillas.
    // Ancho casilla: 640 / 8 = 80 píxeles.
    // Alto casilla:  480 / 8 = 60 píxeles.
    wire [3:0] col = x / 80;
    wire [3:0] row = y / 60;
    
    // Si sumamos la fila y columna, las casillas pares son de un color y las impares de otro.
    // Un truco digital es usar la compuerta XOR con el bit menos significativo [0].
    wire is_white_square = col[0] ^ row[0]; 

    // --------------------------------------------------------
    // 6. Asignación de Color a la Salida VGA
    // --------------------------------------------------------
    // Solo enviamos color si estamos en la región activa. 
    // 4'hF es el máximo brillo (Blanco), 4'h0 es apagado (Negro).
    assign VGA_R = (active_video && is_white_square) ? 4'hF : 4'h0;
    assign VGA_G = (active_video && is_white_square) ? 4'hF : 4'h0;
    assign VGA_B = (active_video && is_white_square) ? 4'hF : 4'h0;

endmodule