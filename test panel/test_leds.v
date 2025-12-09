module test_leds (
    input wire clk,
    output reg r0, g0, b0,
    output reg r1, g1, b1,
    output reg [4:0] addr,
    output reg clk_out,
    output reg latch,
    output reg oe
);

    // Contador principal
    reg [15:0] cnt = 0;
    
    // Patrón de prueba configurable
    parameter R_PATTERN = 1'b1;  
    parameter G_PATTERN = 1'b0;
    parameter B_PATTERN = 1'b0;
    
    always @(posedge clk) begin
        cnt <= cnt + 1;
        
        // RGB: Patrón fijo (BLANCO por defecto)
        // Puedes cambiarlos a 0 para apagar colores
        r0 <= R_PATTERN;
        g0 <= G_PATTERN;
        b0 <= B_PATTERN;
        r1 <= R_PATTERN;
        g1 <= G_PATTERN;
        b1 <= B_PATTERN;
        

        clk_out <= cnt[0];

        addr <= cnt[15:8];
        
        latch <= (cnt[6:0] == 7'd63);
    
        oe <= 1'b0;
    end

endmodule
