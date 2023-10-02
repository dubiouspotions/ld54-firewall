INITIALIZE_LEVEL:
; initialize game data
	LDA #70
	STA player_1 + Player::pos + Vector2::xcoordhi
	LDA #180
	STA player_2 + Player::pos + Vector2::xcoordhi
	LDA #$80
	STA player_1 + Player::pos + Vector2::ycoordhi
	STA player_2 + Player::pos + Vector2::ycoordhi
	LDA #%01000000
	STA player_1 + Player::flags


	LDX	#$00
	STX fire_location_left
	LDX	#$F8
	STX fire_location_right

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
	LDX winner
	CPX #1
	BEQ skip_update_if_winner

	JSR RESPOND_TO_INPUT
	JSR DO_PHYSICS
	JSR MOVE_FIRE
	JSR ANIMATE_FIRE
	JSR EVALUATE_WINNING_CONDITION
skip_update_if_winner:
	


	RTS


; ---- input handling

.macro HANDLE_PLAYER_INPUT	PLAYER
.scope
	LDA PLAYER + Player::dash_cooldown
	CMP #0
	BEQ check_left
	DEC PLAYER + Player::dash_cooldown

check_left:
	LDA PLAYER + Player::buttons
	AND #BTN_LEFT
	BEQ check_right
		LDA PLAYER + Player::flags
		AND #%10111111 ; clear "facing right" flag

		STA PLAYER + Player::flags
		LDA PLAYER + Player::vel + Vector1::xcoord
		CMP #<-50 ; max left speed
		BMI check_right
		BEQ check_right
		
		LDA #<-10 ; speed increase per frame
		CLC
		ADC PLAYER + Player::vel + Vector1::xcoord
		STA PLAYER + Player::vel + Vector1::xcoord
check_right:
	LDA PLAYER + Player::buttons
	AND #BTN_RIGHT
	BEQ check_movement
		LDA PLAYER + Player::flags
		ORA #%01000000 ; set "facing right" flag
		STA PLAYER + Player::flags

		LDA PLAYER + Player::vel + Vector1::xcoord
		CMP #50 ; max right speed
		BPL check_movement
		
		LDA #10 ; speed increase per frame
		CLC
		ADC PLAYER + Player::vel + Vector1::xcoord
		STA PLAYER + Player::vel + Vector1::xcoord
check_movement:
	LDA PLAYER + Player::buttons
	AND # BTN_RIGHT | BTN_LEFT
	BNE check_up
		LDA PLAYER + Player::vel + Vector1::xcoord
		CMP #0
		BEQ check_up
		BMI handle_negative
		handle_positive:
			CLC
			SBC #4 ; speed decrease per frame
			STA PLAYER + Player::vel + Vector1::xcoord
			JMP check_up
		handle_negative:
			CLC
			ADC #4 ; speed decrease per frame
			STA PLAYER + Player::vel + Vector1::xcoord
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
		LDA PLAYER + Player::dash_cooldown
		CMP #0
		BNE done
		LDA #40 ; cooldown time in frames
		STA PLAYER + Player::dash_cooldown
		; set max speed in the direction you're facing
		LDA PLAYER + Player::flags
		AND #%01000000
		BNE facing_right
		facing_left:
			LDA #<-117
			STA PLAYER + Player::vel + Vector1::xcoord
			JMP done
		facing_right:
			LDA #117
			STA PLAYER + Player::vel + Vector1::xcoord
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
; add the 8-bit signed velocity to the 16-bit unsigned position
; https://codebase64.org/doku.php?id=base:signed_8bit_16bit_addition
; first, precalculate the sign-extended high byte in X
	ldx #$00
	lda PLAYER + Player::vel + Vector1::xcoord
	bpl :+
		dex ; high byte in X becomes $ff -> denotes negative 16bit value
:
; then do normal 16-bit addition
	CLC
	ADC PLAYER + Player::pos + Vector2::xcoordlo
	STA PLAYER + Player::pos + Vector2::xcoordlo
	TXA
	ADC PLAYER + Player::pos + Vector2::xcoordhi
	STA PLAYER + Player::pos + Vector2::xcoordhi
.endscope
.endmacro

.macro DETECT_COLLISION PLAYER, OTHER
.scope
	; can only collide while dashing
	LDA PLAYER + Player::dash_cooldown
	CMP #0
	BEQ no_collision

	; can't collide if other player is dashing
	LDA OTHER + Player::dash_cooldown
	CMP #0
	BNE no_collision

	; are we on the right side of the left bounds of enemy?
	LDA PLAYER + Player::pos + Vector2::xcoordhi
	CMP OTHER  + Player::pos + Vector2::xcoordhi
	BCC no_collision
	
	; are we on the left side of the right bounds of enemy?
	; i e, are we horizontally inside their bounding box?
	LDA OTHER + Player::pos + Vector2::xcoordhi
	CLC
	ADC #8 ; width of player minus fudge factor
	CMP PLAYER  + Player::pos + Vector2::xcoordhi
	BCC no_collision

	; TODO: Test top and bottom bounds too

; HIT! Give enemy our velocity
	LDA PLAYER + Player::vel + Vector1::xcoord
	STA OTHER  + Player::vel + Vector1::xcoord
	LDA #0
	STA PLAYER + Player::vel + Vector1::xcoord

	; TODO: sometimes we get stuck? push player away from us once maybe

no_collision:
.endscope
.endmacro

DO_PHYSICS:
	; movement_physics is called so many times because character is moving too slow
	; and my subpixel movement code sucks. This is a hack to speed up char movement.
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_1
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2
	MOVEMENT_PHYSICS player_2

	DETECT_COLLISION player_1, player_2
	DETECT_COLLISION player_2, player_1

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
	CMP PLAYER + Player::pos + Vector2::xcoordhi
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
	LDA PLAYER + Player::pos + Vector2::xcoordhi
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

	LDA player_1 + Player::dead
	ADC player_2 + Player::dead
	
	CMP #0
	BEQ no_winner
		LDX winner
		INX
		STX winner
	no_winner:

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