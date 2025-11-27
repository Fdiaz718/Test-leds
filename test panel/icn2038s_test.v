// Módulo: icn2038s_test.v
// Test de diagnóstico - Patrones muy simples para debug

module icn2038s_test (
    input wire clk,
    
    output wire r0, g0, b0,
    output wire r1, g1, b1,
    output wire clk_out,
    output wire latch,
    output wire oe,
    output wire [4:0] addr
);

    localparam BITS_PER_CHANNEL = 64;
    localparam NUM_ROWS = 32;
    
    localparam IDLE = 3'd0;
    localparam SEND_DATA = 3'd1;
    localparam LATCH_CMD = 3'd2;
    localparam DISPLAY = 3'd3;
    localparam NEXT_ROW = 3'd4;
    
    reg [2:0] state = IDLE;
    reg [6:0] bit_counter = 0;
    reg [2:0] latch_counter = 0;
    reg [7:0] display_counter = 0;
    reg [4:0] current_row = 0;
    reg [23:0] pattern_timer = 0;
    reg [3:0] test_pattern = 0;
    
    // CLK rápido
    reg [1:0] clk_div = 0;
    reg clk_fast = 0;
    
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
        if (clk_div == 2'd3) begin
            clk_fast <= ~clk_fast;
            clk_div <= 0;
        end
    end
    
    // Salidas
    reg r0_reg = 0, g0_reg = 0, b0_reg = 0;
    reg r1_reg = 0, g1_reg = 0, b1_reg = 0;
    reg clk_out_reg = 0;
    reg latch_reg = 0;
    reg oe_reg = 1;
    reg [4:0] addr_reg = 0;
    
    // Buffers
    reg [BITS_PER_CHANNEL-1:0] data_r0, data_g0, data_b0;
    reg [BITS_PER_CHANNEL-1:0] data_r1, data_g1, data_b1;
    
    // Patrones SIMPLIFICADOS para debug
    always @(*) begin
        // Por defecto TODO APAGADO
        data_r0 = {BITS_PER_CHANNEL{1'b0}};
        data_g0 = {BITS_PER_CHANNEL{1'b0}};
        data_b0 = {BITS_PER_CHANNEL{1'b0}};
        data_r1 = {BITS_PER_CHANNEL{1'b0}};
        data_g1 = {BITS_PER_CHANNEL{1'b0}};
        data_b1 = {BITS_PER_CHANNEL{1'b0}};
        
        case (test_pattern)
            // Patrón 0: TODO APAGADO (negro)
            4'd0: begin
                // Todo en 0 (ya está)
            end
            
            // Patrón 1: Solo R0 encendido
            4'd1: begin
                data_r0 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 2: Solo G0 encendido
            4'd2: begin
                data_g0 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 3: Solo B0 encendido
            4'd3: begin
                data_b0 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 4: Solo R1 encendido
            4'd4: begin
                data_r1 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 5: Solo G1 encendido
            4'd5: begin
                data_g1 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 6: Solo B1 encendido
            4'd6: begin
                data_b1 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 7: R0 + G0 (amarillo)
            4'd7: begin
                data_r0 = {BITS_PER_CHANNEL{1'b1}};
                data_g0 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 8: G0 + B0 (cyan)
            4'd8: begin
                data_g0 = {BITS_PER_CHANNEL{1'b1}};
                data_b0 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            // Patrón 9: Todos encendidos (blanco)
            4'd9: begin
                data_r0 = {BITS_PER_CHANNEL{1'b1}};
                data_g0 = {BITS_PER_CHANNEL{1'b1}};
                data_b0 = {BITS_PER_CHANNEL{1'b1}};
                data_r1 = {BITS_PER_CHANNEL{1'b1}};
                data_g1 = {BITS_PER_CHANNEL{1'b1}};
                data_b1 = {BITS_PER_CHANNEL{1'b1}};
            end
            
            default: begin
                // Todo apagado
            end
        endcase
    end
    
    // Máquina de estados
    always @(posedge clk_fast) begin
        case (state)
            IDLE: begin
                bit_counter <= 0;
                latch_counter <= 0;
                display_counter <= 0;
                current_row <= 0;
                r0_reg <= 0; g0_reg <= 0; b0_reg <= 0;
                r1_reg <= 0; g1_reg <= 0; b1_reg <= 0;
                clk_out_reg <= 0;
                latch_reg <= 0;
                oe_reg <= 1;
                addr_reg <= 0;
                state <= SEND_DATA;
            end
            
            SEND_DATA: begin
                oe_reg <= 1;
                addr_reg <= current_row;
                
                if (bit_counter < BITS_PER_CHANNEL) begin
                    if (clk_out_reg == 0) begin
                        r0_reg <= data_r0[BITS_PER_CHANNEL - 1 - bit_counter];
                        g0_reg <= data_g0[BITS_PER_CHANNEL - 1 - bit_counter];
                        b0_reg <= data_b0[BITS_PER_CHANNEL - 1 - bit_counter];
                        r1_reg <= data_r1[BITS_PER_CHANNEL - 1 - bit_counter];
                        g1_reg <= data_g1[BITS_PER_CHANNEL - 1 - bit_counter];
                        b1_reg <= data_b1[BITS_PER_CHANNEL - 1 - bit_counter];
                        clk_out_reg <= 1;
                    end else begin
                        clk_out_reg <= 0;
                        bit_counter <= bit_counter + 1;
                    end
                end else begin
                    state <= LATCH_CMD;
                    latch_counter <= 0;
                end
            end
            
            LATCH_CMD: begin
                latch_reg <= 1;
                
                if (latch_counter < 6) begin
                    clk_out_reg <= ~clk_out_reg;
                    if (clk_out_reg == 1)
                        latch_counter <= latch_counter + 1;
                end else begin
                    latch_reg <= 0;
                    clk_out_reg <= 0;
                    state <= DISPLAY;
                    display_counter <= 0;
                end
            end
            
            DISPLAY: begin
                oe_reg <= 0;
                display_counter <= display_counter + 1;
                
                if (display_counter == 8'd50) begin
                    state <= NEXT_ROW;
                end
            end
            
            NEXT_ROW: begin
                oe_reg <= 1;
                
                if (current_row == NUM_ROWS - 1) begin
                    current_row <= 0;
                    
                    // Cambiar patrón cada ~1 segundo
                    pattern_timer <= pattern_timer + 1;
                    if (pattern_timer[23]) begin
                        pattern_timer <= 0;
                        test_pattern <= test_pattern + 1;
                        if (test_pattern >= 9)
                            test_pattern <= 0;
                    end
                end else begin
                    current_row <= current_row + 1;
                end
                
                state <= SEND_DATA;
                bit_counter <= 0;
            end
            
            default: state <= IDLE;
        endcase
    end
    
    assign r0 = r0_reg;
    assign g0 = g0_reg;
    assign b0 = b0_reg;
    assign r1 = r1_reg;
    assign g1 = g1_reg;
    assign b1 = b1_reg;
    assign clk_out = clk_out_reg;
    assign latch = latch_reg;
    assign oe = oe_reg;
    assign addr = addr_reg;

endmodule
