INITIALIZE_LEVEL:
; initialize game data
	LDA #70
	STA player_1 + Player::pos + Vector::xcoord
	LDA #180
	STA player_2 + Player::pos + Vector::xcoord
	LDA #$80
	STA player_1 - Player::pos + Vector::ycoord
	STA player_2 - Player::pos + Vector::ycoord

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
	
	RTS

UPDATE_LEVEL:
	JSR RESPOND_TO_INPUT
	JSR DO_PHYSICS
	JSR MOVE_FIRE
	JSR ANIMATE_FIRE
	JSR EVALUATE_WINNING_CONDITION

	RTS


; ---- input handling

.macro HANDLE_PLAYER_INPUT	PLAYER
.scope
check_left:
	LDA PLAYER + Player::buttons
	AND #BTN_LEFT
	BEQ check_right
		LDA PLAYER + Player::flags
		AND #%10111111 ; clear "facing right" flag
		STA PLAYER + Player::flags
		DEC PLAYER + Player::vel + Vector1::xcoord
check_right:
	LDA PLAYER + Player::buttons
	AND #BTN_RIGHT
	BEQ check_movement
		LDA PLAYER + Player::flags
		ORA #%01000000 ; set "facing right" flag
		STA PLAYER + Player::flags
		INC PLAYER + Player::vel + Vector1::xcoord
check_movement:
	LDA PLAYER + Player::buttons
	AND # BTN_RIGHT | BTN_LEFT
	BNE check_up
		LDA PLAYER + Player::vel + Vector1::xcoord
		CMP #0
		BEQ check_up
		BMI handle_negative
		handle_positive:
			DEC PLAYER + Player::vel + Vector1::xcoord
			JMP check_up
		handle_negative:
			INC PLAYER + Player::vel + Vector1::xcoord
check_up:
	LDA PLAYER + Player::buttons
	AND #BTN_UP
	BEQ check_down
		nop
check_down:
	LDA PLAYER + Player::buttons
	AND #BTN_DOWN
	BEQ check_a
		nop
check_a:
	LDA PLAYER + Player::buttons
	AND #BTN_A
	BEQ check_b
		nop
check_b:
	LDA PLAYER + Player::buttons
	AND #BTN_B
	BEQ done
		nop
done:
.endscope
.endmacro

; https://famicom.party/book/16-input/
RESPOND_TO_INPUT:
	HANDLE_PLAYER_INPUT player_1
	HANDLE_PLAYER_INPUT player_2
	RTS

; ----------- PHYSICS --------

.macro MOVEMENT_PHYSICS	PLAYER
.scope
	CLC
	LDA PLAYER + Player::pos + Vector::xcoord
	ADC PLAYER + Player::vel + Vector1::xcoord
	STA PLAYER + Player::pos + Vector::xcoord

.endscope
.endmacro

DO_PHYSICS:
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_2
	RTS



; ------ fire handling

MOVE_FIRE:
	LDX fire_move_counter
	INX
	STX fire_move_counter
	CPX #254
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
.scope
	CLC
	LDA fire_location_left
	ADC #8 ; width of the fire sprite
	CMP PLAYER + Player::pos + Vector::xcoord 
	BCC not_dead_left ; FireLeftX - PlayerX = ?: If minus, not dead.
	LDY PLAYER + Player::dead
	INY
	STY PLAYER + Player::dead
	not_dead_left:
.endscope
.endmacro

.macro IS_PLAYER_IN_RIGHT_FIRE	PLAYER
.scope
	CLC
	LDA PLAYER + Player::pos + Vector::xcoord 
	ADC #16 ; width of the player sprite
	CMP fire_location_right 
	BCC not_dead_right ; PlayerX+8 - FireRightX = ?: If positive, not dead.
	LDY PLAYER + Player::dead
	INY
	STY PLAYER + Player::dead
	not_dead_right:
.endscope
.endmacro

.macro IS_PLAYER_DEAD	PLAYER
.scope
	IS_PLAYER_IN_LEFT_FIRE PLAYER
	IS_PLAYER_IN_RIGHT_FIRE PLAYER
.endscope
.endmacro

EVALUATE_WINNING_CONDITION:
	IS_PLAYER_DEAD player_1
	IS_PLAYER_DEAD player_2
	RTS


DRAW_LEVEL:
; Draw players
	DRAW_PLAYER player_1, mem_sprites
	DRAW_PLAYER player_2, mem_sprites + 4*4

	; TODO: update the tilemap to match how far in the fire wall 
	JSR DRAW_FIRE

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
		LDA #%01000010
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
		LDA	fire_location_right
		STA mem_fire_sprites, Y
		INY
		PLA
		CPY #128
		BNE draw_right_fire
	RTS