.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $02 ; amount of PRG ROM in 16K units
	.byte $01 ; amount of CHR ROM in 8K units
	.byte $00 ; mapper and mirroring
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
frame_counter:	.RES 1

; GLOBALS

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

	JSR wait_for_vblank

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

	JSR wait_for_vblank

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

; write our initial sprite data to the DMA'd region for OAM
	LDX #$00
load_sprites:
	LDA initial_sprite_data, X
	STA $0200, X
	INX
	CPX #16		; 16 bytes (4 bytes per sprite, 4 sprites total)
	BNE load_sprites

; write our first level to the first nametable
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00
load_tilemap_p1:
	LDA level_tilemap, X
	STA $2007
	INX
	CPX #0
	BNE load_tilemap_p1
load_tilemap_p2:
	LDA level_tilemap+256, X
	STA $2007
	INX
	CPX #0
	BNE load_tilemap_p2
load_tilemap_p3:
	LDA level_tilemap+512, X
	STA $2007
	INX
	CPX #0
	BNE load_tilemap_p3
load_tilemap_p4:
	LDA level_tilemap+768, X
	STA $2007
	INX
	CPX #0
	BNE load_tilemap_p4

; write our first level's palette data to the first nametable
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	LDX #$00
load_tilemap_color:
	LDA level_tilemap_palette, X
	STA $2007
	INX
	CPX #64
	BNE load_tilemap_color


; reset scroll
	LDA #$00
	STA $2005
	STA $2005

; Done with setup! Enable interrupts again!
	CLI					; enable interrupts
	
	LDA #%10010000 		; please generate VBLANK NMIs
	STA $2000

	LDA #%00011110		; please draw sprites and background
	STA $2001


GAME_LOOP:
	JSR UPDATE

	JSR wait_for_vblank
	JSR DRAW

	JMP GAME_LOOP

UPDATE:
	JSR RESPOND_TO_INPUT
	JSR DO_PHYSICS
	JSR EVALUATE_WINNING_CONDITION
	RTS

DRAW:
	; TODO: move the sprites to match player locations
	; TODO: update the tilemap to match how far in the fire wall 
	NOP
	RTS

RESPOND_TO_INPUT:
	; TODO: Listen to controllers and change acceleration/velocity
	RTS

DO_PHYSICS:
	; TODO: Move characters based 
	RTS

EVALUATE_WINNING_CONDITION:
	; TODO: Check if a player is colliding with the fire, and then make the other player win
	RTS

;;;;;; UTILITIES

wait_for_vblank:
	BIT $2002
	BPL wait_for_vblank
	RTS


;;;;;; INTERRUPTS

NMI:
	LDX frame_counter
	INX
	STX frame_counter
	

	LDA #$02		; Load sprite DMA range to PPU
	STA $4014

	RTI


; Data segment

palette_data:
	; Background palettes
	; 	  tileset color 1		unused					fire					unused
	.byte $16, $1D, $26, $37, 	$00, $00, $00, $00, 	$05, $05, $26, $38, 	$00, $00, $00, $00

	; Sprite palettes
	;	  player 1				player 2				fire					unused
	.byte $0F, $11, $22, $33, 	$0F, $15, $25, $35, 	$00, $05, $26, $38, 	$00, $00, $00, $00

initial_sprite_data:
;					 +-------- Flip sprite vertically
;					 |+------- Flip sprite horizontally
;					 ||+------ Priority (0: in front of background; 1: behind background)
;					 |||+++--- Unimplemented (read 0)
;					 ||||||++- Palette (4 to 7) of sprite
	.byte $40, $00, %00000000, $40
	.byte $40, $01, %00000000, $48
	.byte $48, $10, %00000000, $40
	.byte $48, $11, %00000000, $48

level_tilemap:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$08,$09,$0a,$0b,$0b,$0b,$0c,$0d,$0e,$0f,$10,$11,$56,$13,$14,$0b,$15,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$16,$17,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$19,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$1a,$1b,$1c,$1d,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$1e,$06,$1f,$00,$00,$00,$00,$00
	.byte $00,$00,$20,$21,$22,$23,$18,$24,$25,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$26,$27,$28,$00,$29,$2a,$00,$00,$00,$00,$01
	.byte $00,$00,$2b,$2c,$2d,$0b,$11,$2e,$2f,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$30,$31,$32,$33,$34,$35,$00,$00,$00,$00,$01
	.byte $00,$00,$00,$00,$36,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$37,$38,$39,$3a,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$3c,$3d,$3e,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3f,$40,$0b,$0b,$0b,$41,$42,$43,$44,$0b,$0b,$45,$0b,$0b,$0b,$0b,$46,$47,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$49,$0b,$0b,$4a,$4b,$00,$4c,$4d,$0b,$4e,$4f,$50,$0b,$0b,$51,$00,$52,$53,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$3f,$54,$55,$12,$00,$00,$00,$57,$58,$59,$00,$5a,$5b,$5c,$5d,$00,$5e,$5f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$62,$63,$64,$65,$00,$66,$67,$68,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$69,$00,$00,$6a,$6b,$6c,$00,$6d,$6e,$6f,$70,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$71,$72,$73,$0b,$74,$75,$76,$77,$78,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$79,$7a,$7b,$7c,$7d,$7e,$7f,$80,$81,$82,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4c,$83,$84,$85,$86,$35,$87,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$08,$09,$0a,$0b,$0b,$0b,$0c,$0d,$0e,$0f,$10,$11,$56,$13,$14,$0b,$15,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$16,$17,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$19,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$1a,$1b,$1c,$1d,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$1e,$06,$1f,$00,$00,$00,$00,$00
	.byte $00,$00,$20,$21,$22,$23,$18,$24,$25,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$26,$27,$28,$00,$29,$2a,$00,$00,$00,$00,$00
	.byte $00,$00,$2b,$2c,$2d,$0b,$11,$2e,$2f,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$30,$31,$32,$33,$34,$35,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$36,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$37,$38,$39,$3a,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$3c,$3d,$3e,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3f,$40,$0b,$0b,$0b,$41,$42,$43,$44,$0b,$0b,$45,$0b,$0b,$0b,$0b,$46,$47,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$49,$0b,$0b,$4a,$4b,$00,$4c,$4d,$0b,$4e,$4f,$50,$0b,$0b,$51,$00,$52,$53,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$3f,$54,$55,$12,$00,$00,$00,$57,$58,$59,$00,$5a,$5b,$5c,$5d,$00,$5e,$5f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$62,$63,$64,$65,$00,$66,$67,$68,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$69,$00,$00,$6a,$6b,$6c,$00,$6d,$6e,$6f,$70,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$71,$72,$73,$0b,$74,$75,$76,$77,$78,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$79,$7a,$7b,$7c,$7d,$7e,$7f,$80,$81,$82,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4c,$83,$84,$85,$86,$35,$87,$00,$00,$00,$00,$00,$00

level_tilemap_palette:
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101


.segment "VECTORS"
	.word NMI
	.word RESET
.segment "CHARS"
	.incbin "src/rom.chr"