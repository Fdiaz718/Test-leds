// test_leds_tb.v
`timescale 1ns/1ps

module test_leds_tb;

    parameter CLK_PERIOD = 40;  // 25 MHz

    reg clk;
    wire r0, g0, b0;
    wire r1, g1, b1;
    wire [4:0] addr;
    wire clk_out;
    wire latch;
    wire oe;

    integer clk_count     = 0;
    integer latch_count   = 0;
    integer addr_changes  = 0;
    reg [4:0] prev_addr   = 0;
    integer clk_out_period_count = 0;
    reg prev_clk_out = 0;

    // DUT
    test_leds dut (
        .clk(clk),
        .r0(r0), .g0(g0), .b0(b0),
        .r1(r1), .g1(g1), .b1(b1),
        .addr(addr),
        .clk_out(clk_out),
        .latch(latch),
        .oe(oe)
    );

    // Reloj
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 25 MHz
    end

    always @(posedge clk) begin
        clk_count <= clk_count + 1;
    end

    always @(posedge latch) begin
        latch_count <= latch_count + 1;
        $display("[%0t ns] LATCH %0d  addr=%0d",
                 $time, latch_count, addr);
    end

    always @(posedge clk) begin
        if (addr != prev_addr) begin
            addr_changes <= addr_changes + 1;
            prev_addr    <= addr;
        end
    end

    always @(posedge clk) begin
        if (clk_out && !prev_clk_out) begin
            if (clk_out_period_count > 0)
                $display("[%0t ns] CLK_OUT period: %0d cycles",
                         $time, clk_out_period_count);
            clk_out_period_count <= 0;
        end
        else begin
            clk_out_period_count <= clk_out_period_count + 1;
        end
        prev_clk_out <= clk_out;
    end

    // MAIN SEQUENCE
    initial begin
        $dumpfile("test_leds_tb.vcd");
        $dumpvars(0, test_leds_tb);

        $display("\n===== SIMULACIÓN INICIADA =====\n");

        // Esperar un poco
        #200;

        $display("RGB0 = %b %b %b", r0, g0, b0);
        $display("RGB1 = %b %b %b", r1, g1, b1);
        $display("OE   = %b", oe);
        $display("ADDR = %0d", addr);

        $display("\nEsperando 4 pulsos de latch...\n");

        repeat(4) @(posedge latch);

        $display("\n===== RESUMEN =====");
        $display("clk_count     = %0d", clk_count);
        $display("latch_count   = %0d", latch_count);
        $display("addr_changes  = %0d", addr_changes);

        #5_000_000;  // 5ms

        $display("\nFIN DE SIMULACIÓN\n");

        $finish;
    end

    initial begin
        #50_000_000;
        $display("\nTIMEOUT — La simulación tardó demasiado\n");
        $finish;
    end

endmodule

