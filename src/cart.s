.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $01 ; amount of PRG ROM in 16K units
	.byte $01 ; amount of CHR ROM in 8K units
	.byte $00 ; mapper and mirroring
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
VAR:	.RES 1 ; reserve one byte

.segment "STARTUP"

RESET:
	SEI 		; turn off interrupts
	CLD 		; disable decimal mode

	LDX #%10000000	; disable sound IRQ
	STX $4017
	LDX #$00		; disable PCM
	STX $4010

	; initialize stack
	LDX #$FF
	TXS			; transfer to stack

	; Clear PPU
	LDX #$00
	STX $2000
	STX $2001

wait_for_vblank:
	BIT $2002
	BPL wait_for_vblank

	TXA
clear_ram: 			; $0000 - $07FF
	STA $0000, X
	STA $0100, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X

	; actually, $0200-02FF should be #$FF and not zeroes
	LDA #$FF
	STA $0200, X
	LDA #$00

	INX
	CPX #$00
	BNE clear_ram

wait_for_vblank_again:
	BIT $2002
	BPL wait_for_vblank_again

	; Tell PPU to use $0200 as sprite DMA
	LDA #$02
	STA $4014
	nop ; wait for transfer to finish

	; write to PPU's color table at $3F00
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00
load_palettes:
	LDA palette_data, X
	STA $2007
	INX
	CPX #32
	BNE load_palettes

	LDX #$00
load_sprites:
	LDA initial_sprite_data, X
	STA $0200, X
	INX
	CPX #16		; 16 bytes (4 bytes per sprite, 4 sprites total)
	BNE load_sprites

; Done with setup! Enable interrupts again!
	CLI					; enable interrupts
	
	LDA #%10010000 		; please generate VBLANK NMIs
	STA $2000

	LDA #%00011110		; please draw sprites and background
	STA $2001




infiniteloop:
	jmp infiniteloop


NMI:
	LDA #$02		; Load sprite DMA range to PPU
	STA $4014

	RTI


; Data segment

palette_data:
	.byte $00, $0F, $00, $10, 	$00, $0A, $15, $01, 	$00, $29, $28, $27, 	$00, $34, $24, $14 	;background palettes
	.byte $31, $0F, $15, $30, 	$00, $0F, $11, $30, 	$00, $0F, $30, $27, 	$00, $3C, $2C, $1C 	;sprite palettes

initial_sprite_data:
	.byte $40, $00, $00, $40
	.byte $40, $01, $00, $48
	.byte $48, $10, $00, $40
	.byte $48, $11, $00, $48


.segment "VECTORS"
	.word NMI
	.word RESET
.segment "CHARS"
	.incbin "src/rom.chr"