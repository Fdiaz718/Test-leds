// Módulo: icn2038s_minimal.v
// Test ULTRA SIMPLE para ICN2038S
// Solo envía 1s continuamente sin comandos complejos
// Sirve para verificar conectividad básica

module icn2038s_minimal (
    input wire clk,
    output reg r0,        // SIN
    output reg clk_out,   // CLK
    output reg latch,     // LE
    output reg oe,        // OE
    output wire [4:0] addr
);

    // Contador simple
    reg [25:0] counter = 0;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        
        // CLK muy lento (visible con LED si está conectado)
        clk_out <= counter[10];  // ~24 kHz
        
        // SIN: alternar cada cierto tiempo
        r0 <= counter[15];  // ~381 Hz
        
        // LE: pulsos cortos periódicos
        latch <= (counter[18:16] == 3'b100);  // Pulso cada ~5ms
        
        // OE: siempre habilitado (LOW)
        oe <= 0;
    end
    
    assign addr = 5'b00000;

endmodule
