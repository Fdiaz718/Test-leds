#!/usr/bin/env python3
"""
Script de depuración para ICN2038S
Calcula y muestra la secuencia esperada de comandos
"""

def format_bits(value, width):
    """Formatear número como string binario"""
    return format(value, f'0{width}b')

def calculate_timing(clk_freq_mhz):
    """Calcular tiempos basados en frecuencia de reloj"""
    clk_period_ns = 1000.0 / clk_freq_mhz
    print(f"\n=== TIMING ANALYSIS ===")
    print(f"Clock frequency: {clk_freq_mhz} MHz")
    print(f"Clock period: {clk_period_ns:.2f} ns")
    
    # Nuestro divisor de reloj
    divided_freq = clk_freq_mhz / 16  # Dividimos por 16 (8 x 2)
    divided_period_us = 1.0 / divided_freq
    print(f"Divided clock: {divided_freq:.2f} MHz ({divided_period_us*1000:.2f} ns)")
    
    # Tiempo para enviar todos los datos
    num_chips = 24
    bits_per_chip = 16
    total_bits = num_chips * bits_per_chip
    
    time_to_send_us = total_bits * divided_period_us * 2  # *2 porque necesitamos 2 flancos por bit
    print(f"\nTime to send {total_bits} bits: {time_to_send_us:.2f} µs")
    
    return divided_freq

def show_command_sequence():
    """Mostrar la secuencia de comandos esperada"""
    print("\n=== ICN2038S COMMAND SEQUENCE ===")
    print("\n1. INITIALIZE REG1 (WR_REG1 = 11 CLK pulses with LE=HIGH)")
    print("   Data: 0xFFFF per chip (Gain=100%, all features enabled)")
    print("   Total bits: 384 (24 chips × 16 bits)")
    
    print("\n2. INITIALIZE REG2 (WR_REG2 = 12 CLK pulses with LE=HIGH)")
    print("   Data: 0x0000 per chip (Default configuration)")
    print("   Total bits: 384")
    
    print("\n3. SEND DISPLAY DATA")
    print("   Data: 0xFFFF per chip (All LEDs ON)")
    print("   Total bits: 384")
    
    print("\n4. DATA_LATCH (3 CLK pulses with LE=HIGH)")
    print("   Transfers shift register data to output latches")
    
    print("\n5. ENABLE OUTPUT")
    print("   OE = LOW (active low)")

def show_expected_pattern():
    """Mostrar el patrón esperado en el panel"""
    print("\n=== EXPECTED LED PATTERN ===")
    print("With data 0xFFFF per chip:")
    print("  - All 16 outputs of each chip should be ON")
    print("  - Total LEDs ON: 24 chips × 16 LEDs = 384 LEDs")
    print("\nIf you see NOTHING:")
    print("  1. Check physical connections (especially CLK, SIN, LE, OE)")
    print("  2. Check power supply to ICN2038S chips")
    print("  3. Check R-EXT resistor values")
    print("  4. Verify LED polarity")

def show_troubleshooting():
    """Mostrar guía de resolución de problemas"""
    print("\n=== TROUBLESHOOTING ===")
    print("\n❌ NO LEDs lighting up:")
    print("  - Check OE signal (should be LOW when displaying)")
    print("  - Verify CLK signal is toggling")
    print("  - Check SIN data is changing")
    print("  - Measure voltage on R-EXT pin (should be ~1.24V)")
    print("  - Verify VDD power (3.3V or 5V)")
    
    print("\n⚠️  Some LEDs lighting but wrong pattern:")
    print("  - Data might be inverted or shifted")
    print("  - Check bit order (MSB first)")
    print("  - Verify number of chips in cascade")
    
    print("\n✨ LEDs flashing/flickering:")
    print("  - Normal! Means communication is working")
    print("  - Adjust refresh rate (WAIT_DISPLAY counter)")
    print("  - Check for timing violations")

def calculate_current(r_ext_ohms):
    """Calcular corriente de salida basada en R-EXT"""
    v_rext = 1.24  # Voltaje de referencia interno
    i_out = (v_rext / r_ext_ohms) * 15  # Factor de 15 según datasheet
    print(f"\n=== CURRENT CALCULATION ===")
    print(f"R-EXT: {r_ext_ohms}Ω")
    print(f"Output current per channel: {i_out*1000:.1f} mA")
    print(f"Total current (all 16 channels): {i_out*16*1000:.1f} mA")
    print(f"Power per chip @ 5V: {i_out*16*5:.2f} W")
    print(f"Total power (24 chips): {i_out*16*5*24:.2f} W")

def generate_test_vectors():
    """Generar vectores de prueba para simulación"""
    print("\n=== TEST VECTORS ===")
    
    # REG1
    reg1_data = 0xFFFF
    print(f"REG1 data (per chip): {format_bits(reg1_data, 16)}")
    
    # REG2
    reg2_data = 0x0000
    print(f"REG2 data (per chip): {format_bits(reg2_data, 16)}")
    
    # Display data
    display_data = 0xFFFF
    print(f"Display data (per chip): {format_bits(display_data, 16)}")
    
    # Comando data latch
    print("\nCommand LE pulse counts:")
    print("  WR_REG1: 11 pulses")
    print("  WR_REG2: 12 pulses")
    print("  DATA_LATCH: 3 pulses")

def main():
    print("=" * 60)
    print("ICN2038S DEBUG HELPER")
    print("=" * 60)
    
    # Timing
    calculate_timing(25.0)  # 25 MHz clock
    
    # Secuencia de comandos
    show_command_sequence()
    
    # Patrón esperado
    show_expected_pattern()
    
    # Cálculo de corriente (ejemplo con R-EXT típico)
    calculate_current(1230)  # 1.23kΩ para ~15mA
    
    # Vectores de prueba
    generate_test_vectors()
    
    # Troubleshooting
    show_troubleshooting()
    
    print("\n" + "=" * 60)
    print("For datasheet reference:")
    print("  - Max CLK frequency: 30 MHz")
    print("  - Setup time: 5 ns")
    print("  - Hold time: 5 ns")
    print("  - OE pulse width (min): 40 ns @ 5V")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
