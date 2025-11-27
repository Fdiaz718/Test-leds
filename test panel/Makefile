# Makefile para test ICN2038S con FPGA ECP5 (5A-75E)

# Configuración del proyecto
PROJECT = icn2038s_test
TOP_MODULE = icn2038s_minimal

# Archivos fuente
SOURCES = icn2038s_minimal.v

# Directorio de construcción
BUILD_DIR = build

# Herramientas
YOSYS = yosys
NEXTPNR = nextpnr-ecp5
ECPPACK = ecppack

# Configuración FPGA (5A-75E v8.2)
DEVICE = 25k
PACKAGE = CABGA256
SPEED = 7

# Archivo de restricciones
LPF_FILE = constraints_icn2038s_test.lpf

# Colores para output
COLOR_RESET = \033[0m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

.PHONY: all clean synth pnr bitstream program dirs

# Target principal
all: dirs bitstream

# Crear directorios
dirs:
	@echo "$(COLOR_BLUE)Creando directorios...$(COLOR_RESET)"
	@mkdir -p $(BUILD_DIR)

# Síntesis con Yosys
synth: dirs
	@echo "$(COLOR_BLUE)Iniciando síntesis con Yosys...$(COLOR_RESET)"
	$(YOSYS) -p "read_verilog $(SOURCES); \
	            synth_ecp5 -top $(TOP_MODULE) -json $(BUILD_DIR)/$(PROJECT).json" \
	            -l $(BUILD_DIR)/yosys.log
	@echo "$(COLOR_GREEN)Síntesis completada!$(COLOR_RESET)"

# Place and Route con nextpnr
pnr: synth
	@echo "$(COLOR_BLUE)Iniciando Place & Route con nextpnr...$(COLOR_RESET)"
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
	           --json $(BUILD_DIR)/$(PROJECT).json \
	           --lpf $(LPF_FILE) \
	           --textcfg $(BUILD_DIR)/$(PROJECT).config \
	           --log $(BUILD_DIR)/nextpnr.log
	@echo "$(COLOR_GREEN)Place & Route completado!$(COLOR_RESET)"

# Generar bitstream
bitstream: pnr
	@echo "$(COLOR_BLUE)Generando bitstream...$(COLOR_RESET)"
	$(ECPPACK) --compress --svf $(BUILD_DIR)/$(PROJECT).svf \
	           $(BUILD_DIR)/$(PROJECT).config \
	           $(BUILD_DIR)/$(PROJECT).bit
	@echo "$(COLOR_GREEN)Bitstream generado: $(BUILD_DIR)/$(PROJECT).bit$(COLOR_RESET)"

# Programar FPGA (usando openFPGALoader con ft232RL)
program: bitstream
	@echo "$(COLOR_BLUE)Programando FPGA...$(COLOR_RESET)"
	openFPGALoader --cable ft232RL --pins=0:3:4:1 --freq 3000000 -b colorlight $(BUILD_DIR)/$(PROJECT).bit
	@echo "$(COLOR_GREEN)FPGA programada!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Deberías ver algunos LEDs encendidos en tu panel$(COLOR_RESET)"

# Estadísticas del diseño
stats: synth
	@echo "$(COLOR_BLUE)=== Estadísticas del Diseño ===$(COLOR_RESET)"
	@grep -A 20 "Printing statistics" $(BUILD_DIR)/yosys.log

# Limpiar archivos generados
clean:
	@echo "$(COLOR_YELLOW)Limpiando archivos generados...$(COLOR_RESET)"
	rm -rf $(BUILD_DIR)
	@echo "$(COLOR_GREEN)Limpieza completada!$(COLOR_RESET)"

# Ayuda
help:
	@echo "$(COLOR_BLUE)=== Makefile para test ICN2038S ===$(COLOR_RESET)"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  $(COLOR_GREEN)make all$(COLOR_RESET)       - Compilar y generar bitstream"
	@echo "  $(COLOR_GREEN)make program$(COLOR_RESET)   - Programar FPGA"
	@echo "  $(COLOR_GREEN)make clean$(COLOR_RESET)     - Limpiar archivos generados"
	@echo "  $(COLOR_GREEN)make stats$(COLOR_RESET)     - Ver estadísticas del diseño"
	@echo ""
	@echo "$(COLOR_YELLOW)Test esperado:$(COLOR_RESET)"
	@echo "  - Deberías ver LEDs encendidos en patrón (primeros 8 de cada grupo de 16)"
	@echo "  - Si no ves nada, verifica las conexiones del conector J16"
	@echo ""
