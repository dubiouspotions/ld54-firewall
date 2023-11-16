.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $02 ; amount of PRG ROM in 16K units
	.byte $01 ; amount of CHR ROM in 8K units
	.byte $00 ; mapper and mirroring
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00

; Type definitions

.struct Vector2
	xcoordhi	.byte ; pixel location
	xcoordlo	.byte ; subpixel location
	ycoordhi	.byte
	ycoordlo	.byte
.endstruct
.struct Vector1
	xcoord	.byte
	ycoord	.byte
.endstruct

.struct Player
	pos		.tag Vector2
	vel		.tag Vector1
	flags	.byte ; gdxx xxxx
				;  g: whether player is on the ground
				;  d: 0 means facing left, 1 means facing right
	buttons	.byte
	buttons_pressed	.byte ; just buttons pressed this frame
	dash_cooldown	.byte
	dead	.byte
	score	.byte
.endstruct

.struct Sprite
	ycoord	.byte
	index	.byte
	flags	.byte
	xcoord	.byte
.endstruct

.enum	Scenes
	logo = 0
	mainmenu = 2
	level = 4
	win = 6
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

walk_speed  = 50 ; in decimal, for some reason
walk_accel	= 10 ; vel increase per frame
walk_decel	=  2 ; vel decrease per frame
boost_speed = 100 ; walk_speed+boost_speed must be 254

; ---------- ZERO PAGE ------------

.segment "ZEROPAGE"
frame_counter:			.RES 1
player_1:				.tag Player
player_2:				.tag Player
sleeping:				.RES 1
nmi_lock:				.RES 1

.segment "BSS"
current_scene: 			.RES 1
wanted_scene: 			.RES 1
fire_location_left: 	.RES 1
fire_location_right: 	.RES 1
fire_move_counter:		.RES 1
fire_animation_index:	.RES 1
fire_animation_counter:	.RES 1
win_screen_counter:		.RES 1
win_palette_index:		.RES 1
winner:					.RES 1
logo_counter:			.RES 1
buttons_tmp:			.RES 1

indirect_ptr:			.RES 2
indirect_nmi_ptr:		.RES 2

; ---------- CODE ------------

.segment "CODE"

RESET:
	SEI 		; turn off interrupts
	CLD 		; disable decimal mode

	; clear APU
	LDX #%10000000	; disable sound IRQ
	STX $4017
	LDX #$00		; disable DMC IRQ/DPCM
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


; start out on the game scene for now
	LDA #Scenes::logo
	STA wanted_scene
	LDA #$FF ; current scene is invalid = please load wanted scene on next draw
	STA current_scene

; reset scroll
	LDA #$00
	STA $2005
	STA $2005

; load audio stuff
	JSR AUDIO_INIT

; Done with setup! Enable interrupts again!
	;CLI					; enable interrupts
	
	LDA #%10010000 		; please generate VBLANK NMIs
	STA $2000

	LDA #%00011110		; please draw sprites and background
	STA $2001


GAME_LOOP:
	JSR UPDATE

	INC sleeping
sleep:
	LDA sleeping
	BNE sleep

	JMP GAME_LOOP

; ------------ SCENE MANAGEMENT ------------

LOAD_SCENE:
	LDX wanted_scene
	LDA scene_initializers, X
	STA indirect_nmi_ptr
	LDA scene_initializers+1, X
	STA indirect_nmi_ptr+1
	JSR indirect_nmi_jsr

	LDX wanted_scene
	STX current_scene
	RTS

indirect_nmi_jsr:
	JMP (indirect_nmi_ptr)


; ----------- GAME LOGIC ---------

UPDATE:
	; update might be called before NMI has loaded scene
	LDX current_scene
	CPX #$FF
	BEQ skip_update

	LDA scene_updaters, X
	STA indirect_ptr
	LDA scene_updaters+1, X
	STA indirect_ptr+1
	JSR indirect_jsr
skip_update:
	RTS

indirect_jsr:
	JMP (indirect_ptr)



; https://www.nesdev.org/wiki/Controller_reading_code
.macro READ_JOYPAD PLAYER, MEM
.scope
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta MEM
    sta buttons_tmp
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta MEM
joy1_loop:
    lda MEM
    lsr a	       ; bit 0 -> Carry
    rol buttons_tmp  ; Carry -> bit 0; bit 7 -> Carry
    bcc joy1_loop

	; now, figure out which buttons were pressed this particular frame
	lda PLAYER + Player::buttons
	eor buttons_tmp
	and buttons_tmp
	sta PLAYER + Player::buttons_pressed

	; finally, save the current button state for the player
	lda buttons_tmp
	sta PLAYER + Player::buttons
.endscope
.endmacro


; ----------- DRAWING --------


.macro DRAW_PLAYER	PLAYER, SPRITE, PALETTE_OFFSET, BASE_COLOR
.scope
; draw y coordinate same always
	LDX PLAYER + Player::pos + Vector2::ycoordhi
	STX SPRITE +  0 + Sprite::ycoord
	STX SPRITE +  4 + Sprite::ycoord
	TXA
	CLC
	ADC #7
	STA SPRITE +  8 + Sprite::ycoord
	STA SPRITE + 12 + Sprite::ycoord

; blink sprite if cooling down

	LDA #$3F
	STA $2006
	LDA #PALETTE_OFFSET+1
	STA $2006

	LDA PLAYER + Player::dash_cooldown
	CMP #0
	BEQ normal_sprite
	CMP #10
	BCS highlighted_sprite
	AND #%00000010
	BNE normal_sprite
highlighted_sprite:
	LDA #BASE_COLOR
	STA $2007
	JMP done
normal_sprite:
	LDA #BASE_COLOR + $10
	STA $2007
done:
	; ?? I have to reset the PPU address pointer afterwards? otherwise scroll gets messy?
	LDA #$00
	STA $2006
	LDA #$00
	STA $2006

; draw dead sprite if dead
	LDX PLAYER + Player::dead
	CPX #0
	BEQ dont_draw_dead
	LDA frame_counter
	AND #%00001000
	BNE dont_draw_dead
	LDA PLAYER + Player::flags
	ORA #%00000011
	STA SPRITE +  0 + Sprite::flags
	STA SPRITE +  4 + Sprite::flags
	STA SPRITE +  8 + Sprite::flags
	STA SPRITE + 12 + Sprite::flags
dont_draw_dead:

; if facing right, jump down and draw flipped
	LDA PLAYER + Player::flags
	AND #%01000000
	BNE draw_flipped

	LDX PLAYER + Player::pos + Vector2::xcoordhi
	STX SPRITE +  0 + Sprite::xcoord
	STX SPRITE +  8 + Sprite::xcoord
	TXA
	CLC
	ADC #7
	STA SPRITE +  4 + Sprite::xcoord
	STA SPRITE + 12 + Sprite::xcoord

	LDA SPRITE +  0 + Sprite::flags
	AND #%10111111
	STA SPRITE +  0 + Sprite::flags
	STA SPRITE +  4 + Sprite::flags
	STA SPRITE +  8 + Sprite::flags
	STA SPRITE + 12 + Sprite::flags

	jmp done_flipping
draw_flipped:
	LDX PLAYER + Player::pos + Vector2::xcoordhi
	STX SPRITE +  4 + Sprite::xcoord
	STX SPRITE +  12 + Sprite::xcoord
	TXA
	CLC
	ADC #7
	STA SPRITE +  0 + Sprite::xcoord
	STA SPRITE +  8 + Sprite::xcoord

	LDA SPRITE +  0 + Sprite::flags
	ORA #%01000000
	STA SPRITE +  0 + Sprite::flags
	STA SPRITE +  4 + Sprite::flags
	STA SPRITE +  8 + Sprite::flags
	STA SPRITE + 12 + Sprite::flags
done_flipping:

; runcycle
	LDA frame_counter
	AND #%00000010
	BNE done_runcycle
	LDA PLAYER + Player::vel + Vector1::xcoord
	CMP #0
	BEQ done_runcycle
	LDA PLAYER + Player::flags
	AND #%10000000
	BEQ done_runcycle

	LDA SPRITE + 12 + Sprite::index
	CMP #$13
	BNE :+
	LDX #$11
	STX SPRITE + 12 + Sprite::index
	JMP done_runcycle
:
	CMP #$11
	BNE :+
	LDX #$14
	STX SPRITE + 12 + Sprite::index
	JMP done_runcycle
:
	CMP #$14
	BNE done_runcycle
	LDX #$13
	STX SPRITE + 12 + Sprite::index


done_runcycle:
.endscope
.endmacro

DRAW:
	LDX current_scene
	LDA scene_drawers, X
	STA indirect_nmi_ptr
	LDA scene_drawers+1, X
	STA indirect_nmi_ptr+1
	JSR indirect_nmi_jsr

	RTS

; ------------- AUDIO --------------------

;.include "audio.inc"
.include "audio_fs.inc"

; ------------ SCENES --------------------

.include "level.inc"
.include "logo.inc"
.include "mainmenu.inc"
.include "win.inc"


; ----------- UTILITIES ------------------

WAIT_FOR_VBLANK:
	BIT $2002
	BPL WAIT_FOR_VBLANK
	RTS



PRINT_NUM:
	CMP #5
	BCC small
large:
	CLC
	ADC #$2E
	JMP print
small:
	CLC
	ADC #$23
print:
	STA $2007

	RTS

;;;;;; INTERRUPTS

NMI:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

; Prevent NMI re-entry
	lda nmi_lock
	beq @lock_nmi
	jmp nmi_cleanup
@lock_nmi:
	lda #1
	sta nmi_lock

; General housekeeping
	LDX frame_counter
	INX
	STX frame_counter

	LDA #$02		; Load sprite DMA range to PPU
	STA $4014

	LDA #$00		; reset scroll
	STA $2005
	STA $2005

; Load data for wanted scene, if it's not already loaded
	LDX current_scene
	CPX wanted_scene
	BEQ nmi_continue

	SEI
	LDX #$00 			; PPU, please hold while you receive new data.
	STX $2000
	STX $2001
	JSR LOAD_SCENE
	

	LDA #%10010000 		; please generate VBLANK NMIs again
	STA $2000
	LDA #%00011110		; please draw sprites and background
	STA $2001
	; XXX: If I enable interrupts I get an IRQ when I do JMP nmi_cleanup and I don't understand why??
	;CLI

	; skip drawing this frame since we're likely no longer in VBLANK
	JMP nmi_done

nmi_continue:


; Draw graphics
	JSR DRAW
; Play audio
	JSR AUDIO_NMI_UPDATE
; Read input
	READ_JOYPAD player_1, mem_JOYPAD1
	READ_JOYPAD player_2, mem_JOYPAD2

; wake game loop now that we're done with vsync work
	LDA #$00
	STA sleeping

nmi_done:
    lda #0
    sta nmi_lock
nmi_cleanup:
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP

	RTI

IRQ:
	nop
	RTI

.segment "RODATA"

scene_initializers:
	.word INITIALIZE_LOGO
	.word INITIALIZE_MAINMENU
	.word INITIALIZE_LEVEL
	.word INITIALIZE_WIN

scene_updaters:
	.word UPDATE_LOGO
	.word UPDATE_MAINMENU
	.word UPDATE_LEVEL
	.word UPDATE_WIN

scene_drawers:
	.word DRAW_LOGO
	.word DRAW_MAINMENU
	.word DRAW_LEVEL
	.word DRAW_WIN


palette_data:
	.incbin "src/palette.dat"
	; palette contents:
	; background:  ground				menus					burnt bg				background
	; foreground:  player 1				player 2				fire					burnt player

initial_sprite_data:
;					 +-------- Flip sprite vertically
;					 |+------- Flip sprite horizontally
;					 ||+------ Priority (0: in front of background; 1: behind background)
;					 |||+++--- Unimplemented (read 0)
;					 ||||||++- Palette (4 to 7) of sprite
; player 1
	.byte $40, $02, %00000000, $40
	.byte $40, $03, %00000000, $48
	.byte $48, $12, %00000000, $40
	.byte $48, $13, %00000000, $48
; player 2
	.byte $40, $02, %00000001, $20
	.byte $40, $03, %00000001, $28
	.byte $48, $12, %00000001, $20
	.byte $48, $13, %00000001, $28

level_tilemap:
	.byte 253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,8,9,10,11,252,252,252,252,252,252,252,8,10,9,11,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,24,25,26,27,252,252,252,252,252,252,252,24,25,26,27,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,40,41,42,43,252,252,252,252,252,252,252,40,41,42,43,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,56,57,58,59,252,252,252,252,252,252,252,56,57,58,59,252,252,252,252,252,252,252,252,252,252,252,252,12,13,14,252,252,72,73,74,75,252,252,252,252,78,79,252,72,73,74,75,252,252,252,12,13,14,252,252,78,79,252,252,28,29,30,252,252,88,89,90,91,252,252,92,93,94,95,252,88,89,90,91,252,252,252,28,29,30,92,93,94,95,252,252,44,45,46,15,252,104,105,106,107,252,252,108,109,110,111,252,104,105,106,107,252,252,15,44,45,46,108,109,110,111,252,47,60,61,62,31,63,120,121,122,123,76,77,124,125,126,127,47,120,121,122,123,76,77,31,60,61,62,124,125,126,127,63,4,1,0,6,1,7,1,0,2,4,2,5,7,5,4,3,7,6,1,0,4,5,0,4,2,6,2,7,4,0,5,1,20,20,20,20,19,19,19,20,20,19,19,20,20,19,20,20,19,19,19,20,19,19,19,19,19,19,19,20,19,20,19,20,16,17,19,80,19,20,19,66,20,20,20,19,66,66,66,18,16,17,18,16,16,16,16,48,32,252,20,252,252,20,252,18,80,34,16,16,48,32,19,66,18,32,80,18,16,16,16,49,50,34,49,66,50,20,20,34,16,16,16,16,16,48,16,33,19,81,81,50,34,17,50,81,34,48,16,33,81,81,81,34,32,20,34,32,50,20,66,66,81,81,80,18,16,33,20,66,252,252,81,66,80,34,16,16,16,33,81,19,81,66,19,19,66,66,20,66,81,81,81,50,81,81,81,65,17,81,81,81,19,252,81,19,81,81,81,81,19,81,19,19,252,19,81,252,252,252,80,20,20,66,66,20,81,81,18,33,34,17,19,81,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253

logo_tilemap:
 .byte 252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,83,86,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,82,83,84,85,86,87,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,98,99,100,101,102,103,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,114,115,116,117,118,119,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,172,142,51,38,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,139,252,142,203,140,158,175,203,190,252,187,175,191,158,175,174,190,252,156,139,173,143,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,251,251,251,251,251,251,251,251,251,251,251,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,251,251,251,251,251,251,251,251,251,251,251,251,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,220,173,139,142,143,252,140,207,220,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,159,139,204,204,143,252,252,252,173,139,190,141,175,172,172,252,252,252,174,143,204,207,174,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,251,251,251,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252
 
mainmenu_tilemap:
	.byte 254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,128,129,130,131,132,133,134,135,136,137,138,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,144,145,146,147,148,149,150,151,152,153,154,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,160,161,162,163,164,165,166,167,168,169,170,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,176,177,178,179,180,181,182,183,184,185,186,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,192,193,194,195,196,197,198,199,200,201,202,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,208,209,210,211,212,213,214,215,216,217,218,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,224,225,226,227,228,229,230,231,232,233,234,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,240,241,242,243,244,245,246,247,248,249,250,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,187,172,139,207,143,189,252,175,174,143,252,252,252,252,187,172,139,207,143,189,252,191,205,175,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,69,252,235,236,252,252,252,252,252,252,252,252,252,252,69,252,235,236,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254

win_tilemap:
 	.byte 252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,220,190,141,175,189,143,220,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,187,172,139,207,143,189,252,175,174,143,252,252,252,252,252,252,187,172,139,207,143,189,252,191,205,175,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,189,175,203,174,142,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,205,158,174,174,143,189,222,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,187,189,143,190,190,252,190,191,139,189,191,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,191,175,252,141,175,174,191,158,174,203,143,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252
 
level_tilemap_palette:
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

logo_tilemap_palette:
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101

mainmenu_tilemap_palette:
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
		
win_tilemap_palette:
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byte %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101

;song_shatterhand:
	;.include "../deps/famistudio/DemoSource/song_shatterhand_ca65.s"
song_walloffire:
	.include "../gamedata/wall_of_fire.inc"

sounds:
	.word @soundtable
	.word @soundtable
@soundtable:
	.word @sfx_ntsc_dash
	.word @sfx_ntsc_hit
	.word @sfx_ntsc_jump
	.word @sfx_ntsc_burn
	.word @sfx_ntsc_start
@sfx_ntsc_dash:
	.byte $8a,$01,$89,$37,$01,$89,$3a,$01,$89,$3c,$01,$89,$3a,$01,$89,$37
	.byte $01,$89,$36,$01,$89,$35,$01,$89,$33,$01,$89,$32,$01,$89,$31,$01
	.byte $00
@sfx_ntsc_hit:
	.byte $8a,$0c,$01,$89,$3d,$01,$89,$3f,$01,$89,$37,$01,$8a,$0b,$89,$30
	.byte $01,$89,$3d,$01,$89,$3f,$01,$89,$37,$01,$89,$34,$01,$00
@sfx_ntsc_jump:	
	.byte $87,$d5,$88,$00,$86,$8f,$89,$f0,$01,$87,$c9,$01,$87,$b3,$01,$86
	.byte $80,$01,$87,$8e,$86,$8f,$01,$00
@sfx_ntsc_burn:
	.byte $89,$f0,$01,$8a,$0e,$89,$33,$01,$89,$36,$01,$89,$3a,$01,$89,$3b
	.byte $01,$89,$3a,$02,$89,$39,$01,$89,$37,$01,$89,$36,$01,$89,$35,$03
	.byte $89,$36,$01,$89,$34,$04,$89,$33,$02,$89,$32,$01,$00
@sfx_ntsc_start:
	.byte $87,$4c,$88,$00,$86,$87,$89,$f0,$01,$87,$61,$01,$87,$77,$01,$87
	.byte $9c,$01,$87,$36,$01,$87,$43,$01,$87,$52,$01,$87,$6a,$01,$87,$84
	.byte $01,$87,$8e,$01,$87,$2c,$01,$87,$34,$01,$87,$3f,$01,$87,$51,$01
	.byte $87,$64,$01,$00

SND_DASH = 0
SND_HIT  = 1
SND_JUMP = 2
SND_BURN = 3
SND_START = 4

.segment "VECTORS"
	.addr NMI
	.addr RESET
	.addr IRQ
.segment "CHR"
	.incbin "src/rom.chr"
