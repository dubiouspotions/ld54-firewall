.PHONY: all build run build/firewall.nes

all: build/firewall.nes

print-%  : ; @echo $* = $($*)

clean:
	rm -rf build
	mkdir -p build
	touch build/.dummy

SOURCES = \
	src/cart.s

OBJECTS = $(patsubst src/%, build/%, $(SOURCES:.s=.o))

build/%.o : src/%.s src/rom.chr
	ca65 -g --cpu 6502 -o $@ $<

build/firewall.nes: $(OBJECTS)
	ld65 $(OBJECTS) --dbgfile build/firewall.dbg -o build/firewall.nes -t nes