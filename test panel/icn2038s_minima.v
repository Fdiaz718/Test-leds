module icn2038s_minimal (
    input wire clk,
    output reg r0, g0, b0,
    output reg r1, g1, b1,
    output reg [4:0] addr,
    output reg clk_out,
    output reg latch,
    output reg oe
);

    // Contadores
    reg [15:0] cnt = 0;
    reg [5:0] col_cnt = 0;
    reg [4:0] row_cnt = 0;
    reg [7:0] display_cnt = 0;
    
    // Estados: 0=cargar columnas, 1=mostrar fila
    reg state = 0;
    
    always @(posedge clk) begin
        cnt <= cnt + 1;
        
        if (state == 0) begin
            // ===================================
            // ESTADO: Cargar 64 columnas
            // ===================================
            oe <= 1'b1;  // Deshabilitar durante carga
            
            // Clock de shift register
            clk_out <= cnt[1];
            
            if (cnt[1:0] == 2'b10) begin
                // RGB: Todo blanco
                r0 <= 1'b1;
                g0 <= 1'b1;
                b0 <= 1'b0;
                r1 <= 1'b1;
                g1 <= 1'b1;
                b1 <= 1'b0;
                
                col_cnt <= col_cnt + 1;
                
                if (col_cnt == 6'd63) begin
                    col_cnt <= 0;
                    latch <= 1'b1;
                    state <= 1;
                    display_cnt <= 0;
                end else begin
                    latch <= 1'b0;
                end
            end
            
        end else begin
            // ===================================
            // ESTADO: Mostrar fila
            // ===================================
            latch <= 1'b0;
            clk_out <= 1'b0;
            oe <= 1'b0;  // Habilitar salida
            
            display_cnt <= display_cnt + 1;
            
            // Mantener fila ~10µs (256 ciclos @ 25MHz)
            if (display_cnt == 8'd255) begin
                // Siguiente fila
                row_cnt <= (row_cnt == 5'd31) ? 5'd0 : (row_cnt + 1'b1);
                addr <= row_cnt;
                state <= 0;
            end
        end
    end

endmodule
