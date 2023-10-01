.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $02 ; amount of PRG ROM in 16K units
	.byte $01 ; amount of CHR ROM in 8K units
	.byte $00 ; mapper and mirroring
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00

; Type definitions

.struct Vector
	xcoord	.word
	ycoord	.word
.endstruct

.struct Player
	pos		.tag Vector
	vel		.tag Vector
	buttons	.byte
	dead	.byte
.endstruct

.struct Sprite
	ycoord	.byte
	index	.byte
	flags	.byte
	xcoord	.byte
.endstruct

.enum	Scenes
	logo
	mainmenu
	level
	win
.endenum

; Memory address constants
mem_sprites = $0200
mem_fire_sprites = $0280
mem_JOYPAD1 = $4016
mem_JOYPAD2 = $4017

; Other constants
BTN_RIGHT   = %00000001
BTN_LEFT    = %00000010
BTN_DOWN    = %00000100
BTN_UP      = %00001000
BTN_START   = %00010000
BTN_SELECT  = %00100000
BTN_B       = %01000000
BTN_A       = %10000000

; ---------- ZERO PAGE ------------

.segment "ZEROPAGE"
frame_counter:			.RES 1
player_1:				.tag Player
player_2:				.tag Player


.segment "BSS"
current_scene: 			.RES 1
wanted_scene: 			.RES 1
fire_location_left: .RES 1
fire_location_right: .RES 1
fire_move_counter:		.RES 1
fire_animation_index:	.RES 1
fire_animation_counter:	.RES 1

; ---------- CODE ------------

.segment "CODE"

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

	JSR WAIT_FOR_VBLANK

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

	JSR WAIT_FOR_VBLANK

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
	STA mem_sprites, X
	INX
	CPX #32		; 16 bytes (4 bytes per sprite, 8 sprites total)
	BNE load_sprites

; write our first level to the first nametable
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

; start out on the game scene for now
	LDA Scenes::level
	STA wanted_scene
	STA current_scene

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

	JSR WAIT_FOR_VBLANK
	JSR DRAW

	JMP GAME_LOOP


; ----------- GAME LOGIC ---------

UPDATE:
	JSR RESPOND_TO_INPUT
	JSR DO_PHYSICS
	JSR MOVE_FIRE
	JSR ANIMATE_FIRE
	JSR EVALUATE_WINNING_CONDITION
	RTS


.macro HANDLE_PLAYER_INPUT	PLAYER
.scope
	LDA PLAYER + Player::buttons
	AND #BTN_LEFT
	BEQ check_right
		DEC PLAYER + Player::pos + Vector::xcoord
check_right:
	LDA PLAYER + Player::buttons
	AND #BTN_RIGHT
	BEQ check_up
		INC PLAYER + Player::pos + Vector::xcoord
check_up:
	LDA PLAYER + Player::buttons
	AND #BTN_UP
	BEQ check_down
		DEC PLAYER + Player::pos + Vector::ycoord
check_down:
	LDA PLAYER + Player::buttons
	AND #BTN_DOWN
	BEQ done
		INC PLAYER + Player::pos + Vector::ycoord
done:
.endscope
.endmacro

; https://famicom.party/book/16-input/
RESPOND_TO_INPUT:
	JSR READ_JOYPADS
	HANDLE_PLAYER_INPUT player_1
	HANDLE_PLAYER_INPUT player_2
	
	RTS

; https://www.nesdev.org/wiki/Controller_reading_code
READ_JOYPADS:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta mem_JOYPAD1
    sta player_1 + Player::buttons
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta mem_JOYPAD1
joy1_loop:
    lda mem_JOYPAD1
    lsr a	       ; bit 0 -> Carry
    rol player_1 + Player::buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc joy1_loop

	RTS
	; let's do it again for joy2
	lda #$01
    sta mem_JOYPAD2
    sta player_2 + Player::buttons
    lsr a
    sta mem_JOYPAD2
joy2_loop:
    lda mem_JOYPAD2
    lsr a
    rol player_2 + Player::buttons
    bcc joy2_loop

    rts

MOVE_FIRE:
	LDX fire_move_counter
	INX
	STX fire_move_counter
	CPX #30
	BNE move_fire_done ; Update fire every X frame
	LDX #$00
	STX fire_move_counter
	LDX fire_location_left
	INX
	STX fire_location_left
	LDA	#$F8
	SBC fire_location_left
	STA fire_location_right
move_fire_done:
	RTS

ANIMATE_FIRE: 
	LDX fire_animation_counter
	INX
	STX fire_animation_counter
	CPX #10
	BNE animate_fire_done ; update fire animation index every X frames
	LDX #$00
	STX fire_animation_counter
	LDX fire_animation_index
	INX
	STX fire_animation_index
	CPX #3
	BNE animate_fire_done
	LDX #$00
	STX fire_animation_index
animate_fire_done: 
	RTS



.macro IS_PLAYER_IN_LEFT_FIRE	PLAYER
	LDA fire_location_left
	ADC #8 ; width of the fire sprite
	CMP PLAYER + Player::pos + Vector::xcoord 
	BMI not_dead_left ; If minus, not dead.
	LDY PLAYER + Player::dead
	INY
	STY PLAYER + Player::dead
	not_dead_left:
.endmacro

.macro IS_PLAYER_IN_RIGHT_FIRE	PLAYER
	LDA PLAYER + Player::pos + Vector::xcoord 
	ADC #8 ; width of the player sprite
	CMP fire_location_right
	BMI not_dead_right
	LDY PLAYER + Player::dead
	INY
	STY PLAYER + Player::dead
	not_dead_right:
.endmacro

.macro IS_PLAYER_DEAD	PLAYER
.scope
	IS_PLAYER_IN_LEFT_FIRE PLAYER
	; IS_PLAYER_IN_RIGHT_FIRE PLAYER
.endscope
.endmacro

EVALUATE_WINNING_CONDITION:
	IS_PLAYER_DEAD player_1
	; IS_PLAYER_DEAD player_2
	RTS


; ----------- PHYSICS --------
DO_PHYSICS:
	; TODO: Move characters based 
	RTS



; ----------- DRAWING --------


.macro DRAW_PLAYER	PLAYER, SPRITE
	LDX PLAYER + Player::pos + Vector::xcoord
	STX SPRITE +  0 + Sprite::xcoord
	STX SPRITE +  8 + Sprite::xcoord
	TXA
	ADC #7
	STA SPRITE +  4 + Sprite::xcoord
	STA SPRITE + 12 + Sprite::xcoord

	LDX PLAYER + Player::pos + Vector::ycoord
	STX SPRITE +  0 + Sprite::ycoord
	STX SPRITE +  4 + Sprite::ycoord
	TXA
	ADC #7
	STA SPRITE +  8 + Sprite::ycoord
	STA SPRITE + 12 + Sprite::ycoord

.endmacro

DRAW:
	; Draw players
	DRAW_PLAYER player_1, mem_sprites
	DRAW_PLAYER player_2, mem_sprites + 4*4
	

	; TODO: update the tilemap to match how far in the fire wall 
	JSR DRAW_FIRE

	NOP
	RTS

DRAW_FIRE:
	LDY #$00
	LDA #$8F
	LDX fire_animation_index
	draw_left_fire:
	 ; Y Value
		SBC #7
		PHA
		STA mem_fire_sprites, Y
		INY 
		; Tile 
		TXA
		ADC #$3F
		STA mem_fire_sprites, Y
		INX
		CPX #3
		BNE continue_draw_left_fire
		LDX #$00
		continue_draw_left_fire:
		INY 
		; Settings
		LDA #%00000010
		STA mem_fire_sprites, Y
		INY
		; X Value
		LDA	fire_location_left
		STA mem_fire_sprites, Y
		INY
		PLA
		CPY #64
		BNE draw_left_fire

	LDA #$8F
	LDX fire_animation_index
	draw_right_fire:
	 ; Y Value
		SBC #7
		PHA
		STA mem_fire_sprites, Y
		INY 
		; Tile 
		TXA
		ADC #$3F
		STA mem_fire_sprites, Y
		INX
		CPX #3
		BNE continue_draw_right_fire
		LDX #$00
		continue_draw_right_fire:
		INY 
		; Settings
		LDA #%00000010
		STA mem_fire_sprites, Y
		INY
		; X Value
		LDA	#$F8
		SBC fire_location_left
		STA mem_fire_sprites, Y
		INY
		PLA
		CPY #128
		BNE draw_right_fire


;;;;;; UTILITIES

WAIT_FOR_VBLANK:
	BIT $2002
	BPL WAIT_FOR_VBLANK
	RTS


;;;;;; INTERRUPTS

NMI:
	LDX frame_counter
	INX
	STX frame_counter
	

	LDA #$02		; Load sprite DMA range to PPU
	STA $4014

	RTI


.segment "RODATA"

palette_data:
	.incbin "src/palette.dat"
	; palette contents:
	; background:  tileset color 1		unused					fire					unused
	; foreground:  player 1				player 2				fire					unused

initial_sprite_data:
;					 +-------- Flip sprite vertically
;					 |+------- Flip sprite horizontally
;					 ||+------ Priority (0: in front of background; 1: behind background)
;					 |||+++--- Unimplemented (read 0)
;					 ||||||++- Palette (4 to 7) of sprite
; player 1
	.byte $40, $00, %00000000, $40
	.byte $40, $01, %00000000, $48
	.byte $48, $10, %00000000, $40
	.byte $48, $11, %00000000, $48
; player 2
	.byte $40, $00, %00000001, $20
	.byte $40, $01, %00000001, $28
	.byte $48, $10, %00000001, $20
	.byte $48, $11, %00000001, $28

level_tilemap:
	.byte 253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,8,9,10,11,252,252,252,252,252,252,252,8,10,9,11,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,24,25,26,27,252,252,252,252,252,252,252,24,25,26,27,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,40,41,42,43,252,252,252,252,252,252,252,40,41,42,43,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,56,57,58,59,252,252,252,252,252,252,252,56,57,58,59,252,252,252,252,252,252,252,252,252,252,252,252,12,13,14,252,252,72,73,74,75,252,252,252,252,78,79,252,72,73,74,75,252,252,252,12,13,14,252,252,78,79,252,252,28,29,30,252,252,88,89,90,91,252,252,92,93,94,95,252,88,89,90,91,252,252,252,28,29,30,92,93,94,95,252,252,44,45,46,15,252,104,105,106,107,252,252,108,109,110,111,252,104,105,106,107,252,252,15,44,45,46,108,109,110,111,252,47,60,61,62,31,63,120,121,122,123,76,77,124,125,126,127,47,120,121,122,123,76,77,31,60,61,62,124,125,126,127,63,4,1,0,6,1,7,1,0,2,4,2,5,7,5,4,3,7,6,1,0,4,5,0,4,2,6,2,7,4,0,5,1,20,20,20,20,19,19,19,20,20,19,19,20,20,19,20,20,19,19,19,20,19,19,19,19,19,19,19,20,19,20,19,20,16,17,19,80,19,20,19,66,20,20,20,19,66,66,66,18,16,17,18,16,16,16,16,48,32,252,20,252,252,20,252,18,80,34,16,16,48,32,19,66,18,32,80,18,16,16,16,49,50,34,49,66,50,20,20,34,16,16,16,16,16,48,16,33,19,81,81,50,34,17,50,81,34,48,16,33,81,81,81,34,32,20,34,32,50,20,66,66,81,81,80,18,16,33,20,66,252,252,81,66,80,34,16,16,16,33,81,19,81,66,19,19,66,66,20,66,81,81,81,50,81,81,81,65,17,81,81,81,19,252,81,19,81,81,81,81,19,81,19,19,252,19,81,252,252,252,80,20,20,66,66,20,81,81,18,33,34,17,19,81,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253

level_tilemap_palette:
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	


.segment "VECTORS"
	.word NMI
	.word RESET
.segment "CHR"
	.incbin "src/rom.chr"