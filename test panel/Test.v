module hub75e_white (
    input  wire clk,        // reloj del sistema
    input  wire reset,

    // Señales del panel HUB75E (salidas)
    output reg R1, G1, B1,
    output reg R2, G2, B2,
    output reg CLK,
    output reg LAT,
    output reg OE,
    output reg A, B, C, D, E
);

    // -------------------------
    // Constantes del panel
    // -------------------------
    localparam WIDTH  = 64;
    localparam SCAN   = 32;

    // -------------------------
    // Generador de slow_clk
    // -------------------------
    reg [7:0] div = 0;
    reg slow_clk = 0;

    always @(posedge clk) begin
        div <= div + 1;
        if (div == 10) begin
            div <= 0;
            slow_clk <= ~slow_clk;  // clock del panel
        end
    end

    // -------------------------
    // Contadores X y fila
    // -------------------------
    reg [5:0] x = 0;       // 0–63 (pixel)
    reg [4:0] row = 0;     // 0–31 (scanline en 1/32)

    always @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            x <= 0;
            row <= 0;
        end else begin
            if (x < WIDTH-1) begin
                x <= x + 1;
            end else begin
                x <= 0;
                row <= (row == SCAN-1) ? 0 : row + 1;
            end
        end
    end

    // -------------------------
    // Direcciones A-E
    // -------------------------
    always @(*) begin
        A = row[0];
        B = row[1];
        C = row[2];
        D = row[3];
        E = row[4];
    end

    // -------------------------
    // Color: pantalla blanca
    // -------------------------
    always @(posedge slow_clk) begin
        R1 <= 1;
        G1 <= 1;
        B1 <= 1;

        R2 <= 1;
        G2 <= 1;
        B2 <= 1;
    end

    // -------------------------
    // CLK, LAT (3 ciclos), OE
    // -------------------------
    reg [1:0] lat_cnt = 0;

    always @(posedge slow_clk) begin
        // --- CLK: pulso por pixel ---
        CLK <= ~CLK;

        // --- Generación de LAT por 3 ciclos ---
        if (x == WIDTH-2) begin
            lat_cnt <= 3;    // activar latch 3 ciclos antes del cambio de línea
        end else if (lat_cnt != 0) begin
            lat_cnt <= lat_cnt - 1;
        end

        LAT <= (lat_cnt != 0) ? 1'b1 : 1'b0;

        // --- OE: apagado (panel siempre encendido) ---
        OE <= 0;
    end

endmodule
