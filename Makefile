.PHONY: all build run build/firewall.nes

all: build/firewall.nes

print-%  : ; @echo $* = $($*)

clean:
	rm -rf build
	mkdir -p build

SOURCES = \
	src/cart.s

OBJECTS = $(patsubst src/%, build/%, $(SOURCES:.s=.o))

build/%.o : src/%.s src/rom.chr
	ca65 --cpu 6502 -o $@ $<

build/firewall.nes: $(OBJECTS)
	ld65 $(OBJECTS) -o build/firewall.nes -t nes