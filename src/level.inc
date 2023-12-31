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

	LDX #10
	STX prng_seed
	LDA #1
	JSR AUDIO_START_MUSIC

	LDX	#$00
	STX fire_location_left
	LDX	#$F8
	STX fire_location_right

	LDX #$00
	STX winner
	STX win_screen_counter
	STX win_palette_index
	STX player_1 + Player::dead
	STX player_2 + Player::dead
	STX player_1 + Player::vel
	STX player_2 + Player::vel
	STX player_1 + Player::dash_cooldown
	STX player_2 + Player::dash_cooldown

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

	LDX p2_is_human
	CPX #0
	BNE skip_p2_cpu
		JSR CHECK_IF_PLAYER_JOINED
		JSR CPU_PLAYER_ACTION
	skip_p2_cpu:
	JSR RESPOND_TO_INPUT
	JSR DO_PHYSICS
	JSR MOVE_FIRE
	JSR ANIMATE_FIRE
	JSR EVALUATE_WINNING_CONDITION
skip_update_if_winner:
	
	JSR HANDLE_WIN_STATE
	
	RTS

CHECK_IF_PLAYER_JOINED:
	LDA player_2 + Player::buttons_pressed
	AND #BTN_A
	BEQ @nope
	; ok, player 2 wants to join!
	LDA #1
	STA p2_is_human
	LDX #Scenes::mainmenu
	STX wanted_scene
	LDA #SND_P2_JOINED
	LDX #FAMISTUDIO_SFX_CH0
	JSR AUDIO_PLAY_SFX
@nope:
	RTS

PRNG:
	CLC
	ldy #8     ; iteration count (generates 8 bits)
	lda prng_seed+0
:
	asl        ; shift the register
	rol prng_seed+1
	bcc :+
	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne :--
	sta prng_seed+0
	cmp #0     ; reload flags
	rts

; ---- player 2 cpu
CPU_PLAYER_ACTION:
	; reset cpu controls
	CLC
	LDA #0
	STA player_2 + Player::buttons_pressed
	STA player_2 + Player::buttons
	
	JSR PRNG
	TAY ; store random number in Y, for later use

	; if face left, dash left if close enough, else check dash right
	LDA player_2 + Player::flags
	AND #%01000000 ; is facing left?
	BNE dash_right_if_close 
		LDX player_1 + Player::pos + Vector2::xcoordhi
		CPX player_2 + Player::pos + Vector2::xcoordhi
		BPL done_dashing ; if we're to the right of player 1, don't dash
			
			; dashing
			LDA player_2 + Player::dash_cooldown
			CMP #0 ; is the cooldown ready
			BNE skip_left_dash
				LDA player_1 + Player::pos + Vector2::xcoordhi
				CLC
				ADC #30 ; add 5 and see if we're on other side (means we're close enough to jump)
				CMP player_2 + Player::pos + Vector2::xcoordhi
				BMI skip_left_dash
					CPY #10
					BCS skip_left_dash
						CLC
						LDA #BTN_B
						STA player_2 + Player::buttons_pressed
						STA player_2 + Player::buttons
						RTS ; do dash then return 
			skip_left_dash: ; if not dash, mayby jump?

			; jumping
			LDA player_1 + Player::pos + Vector2::xcoordhi 
			CLC
			ADC #45 ; add 5 and see if we're on other side (means we're close enough to jump)
			CMP player_2 + Player::pos + Vector2::xcoordhi
			BMI skip_left_jump
				LDA player_2 + Player::flags
				AND #%10000000
				BEQ skip_left_jump
					CPY #3
					BCS skip_left_jump
						CLC
						LDA #BTN_A
						STA player_2 + Player::buttons_pressed
						RTS ; do dash then return 
			skip_left_jump:

		jmp done_dashing

	; if face right 
	dash_right_if_close: 
		LDX player_2 + Player::pos + Vector2::xcoordhi
		CPX player_1 + Player::pos + Vector2::xcoordhi
		BPL done_dashing ; if we're to the right of player 1, don't dash
			
			; dashing
			LDA player_2 + Player::dash_cooldown
			CMP #0 ; is the cooldown ready
			BNE skip_right_dash
				LDA player_2 + Player::pos + Vector2::xcoordhi
				CLC
				ADC #16 ; player width
				ADC #16 ; distance for dash
				CMP player_1 + Player::pos + Vector2::xcoordhi
				BMI skip_right_dash
					CPY #10
					BCS skip_right_dash
						CLC
						LDA #BTN_B
						STA player_2 + Player::buttons_pressed
						STA player_2 + Player::buttons
						RTS ; do dash then return 
			skip_right_dash:

			; jumping
			LDA player_2 + Player::pos + Vector2::xcoordhi
			CLC
			ADC #16 ; player width
			ADC #10 ; distance for jump
			CMP player_1 + Player::pos + Vector2::xcoordhi
			BMI skip_right_jump
				LDA player_2 + Player::flags
				AND #%10000000
				BEQ skip_right_jump
					CPY #3
					BCS skip_right_jump
						LDX #BTN_A
						STX player_2 + Player::buttons_pressed
						RTS ; do dash then return 
			skip_right_jump:

	done_dashing:

	; run left or right
	LDX player_1 + Player::pos + Vector2::xcoordhi
	CPX player_2 + Player::pos + Vector2::xcoordhi
	BMI not_run_right ; run right if p1 is right of p2
		CPY #100 ; only press arrow ~50% of the time
		BCS skip_run_right 
			CLC
			LDA #BTN_RIGHT
			STA player_2 + Player::buttons
			RTS
		skip_run_right:
		CPY #5 ; randomly turn around ~2% of the time
		BCS skip_random_run_left
			CLC
			LDA #BTN_LEFT
			STA player_2 + Player::buttons
		skip_random_run_left:
		RTS
	not_run_right: ; run left if p1 is left of p2
		CPY #100 ; only press arrow ~50% of the time
		BCS skip_run_left
			CLC
			LDA #BTN_LEFT
			STA player_2 + Player::buttons
		skip_run_left:
		CPY #5 ; randomly turn around ~2% of the time
		BCS skip_random_run_right
			CLC
			LDA #BTN_RIGHT
			STA player_2 + Player::buttons
		skip_random_run_right:
		RTS

; ---- input handling

.macro HANDLE_PLAYER_INPUT	PLAYER
.scope
	LDA PLAYER + Player::dash_cooldown
	CMP #0
	BEQ check_player_grounded
	DEC PLAYER + Player::dash_cooldown

check_player_grounded:
; check whether player is on ground
	LDA PLAYER + Player::pos + Vector2::ycoordhi
	CMP #$80
	BCC not_on_ground
is_on_ground:
	LDA #$80 ; put them back on ground in case we're below it
	STA PLAYER + Player::pos + Vector2::ycoordhi
	LDA PLAYER + Player::flags ; store "grounded" flag
	ORA #%10000000
	STA PLAYER + Player::flags
	JMP check_left
not_on_ground:
	LDA PLAYER + Player::flags
	AND #%01111111
	STA PLAYER + Player::flags

check_left:
	LDA PLAYER + Player::buttons
	AND #BTN_LEFT
	BEQ check_right
		LDA PLAYER + Player::flags
		AND #%10111111 ; clear "facing right" flag

		STA PLAYER + Player::flags
		LDA PLAYER + Player::vel + Vector1::xcoord
		BPL walk_left ; positive numbers are always more than negative
		CMP #<-walk_speed ; max left speed
		BMI check_right
		BEQ check_right
	walk_left:
		LDA #<-walk_accel ; speed increase per frame
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
		BMI walk_right ; negative numbers are always more than positive
		CMP #walk_speed ; max right speed
		BPL check_movement
	walk_right:
		LDA #walk_accel ; speed increase per frame
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
			SEC
			SBC #walk_decel ; speed decrease per frame
			STA PLAYER + Player::vel + Vector1::xcoord
			JMP check_up
		handle_negative:
			CLC
			ADC #walk_decel ; speed decrease per frame
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
	LDA PLAYER + Player::buttons_pressed
	AND #BTN_A
	BEQ check_b
		; only allow jumps if we're on the ground
		LDA PLAYER + Player::flags
		TAX
		AND #%10000000
		BEQ check_b
		TXA
		AND #%01111111 ; clear ground flag so we can start jumping
		STA PLAYER + Player::flags
		; and set upwards velocity
		LDA #<-$70
		STA PLAYER + Player::vel + Vector1::ycoord

		LDA #SND_JUMP
		LDX #FAMISTUDIO_SFX_CH0
		JSR AUDIO_PLAY_SFX
check_b:
	LDA PLAYER + Player::buttons
	AND #BTN_B
	BEQ done
		LDA PLAYER + Player::dash_cooldown
		CMP #0
		BNE done
		
		LDA #SND_DASH
		LDX #FAMISTUDIO_SFX_CH0
		JSR AUDIO_PLAY_SFX

		LDA #40 ; cooldown time in frames
		STA PLAYER + Player::dash_cooldown
		; set max speed in the direction you're facing
		LDA PLAYER + Player::flags
		AND #%01000000
		BNE facing_right
		facing_left:
			LDA #<-boost_speed
			STA PLAYER + Player::vel + Vector1::xcoord
			JMP done
		facing_right:
			LDA #boost_speed
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
.macro MOVEMENT_PHYSICS_BASE	PLAYER
.scope
; fall, or if on ground, reset Y velocity
	LDA PLAYER + Player::flags
	AND #%10000000
	BNE stop_falling

	LDA PLAYER + Player::vel + Vector1::ycoord
	CLC
	ADC #5 ; gravity
	STA PLAYER + Player::vel + Vector1::ycoord
	JMP done_falling
stop_falling:
	LDA #0
	STA PLAYER + Player::vel + Vector1::ycoord
done_falling:
.endscope
.endmacro

.macro MOVEMENT_PHYSICS_XY	PLAYER
.scope
; Add the 8-bit signed X velocity to the 16-bit unsigned X position
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

; Add the 8-bit signed Y velocity to the 16-bit unsigned Y position
	ldx #$00
	lda PLAYER + Player::vel + Vector1::ycoord
	bpl :+
		dex
:
; then do normal 16-bit addition
	CLC
	ADC PLAYER + Player::pos + Vector2::ycoordlo
	STA PLAYER + Player::pos + Vector2::ycoordlo
	TXA
	ADC PLAYER + Player::pos + Vector2::ycoordhi
	STA PLAYER + Player::pos + Vector2::ycoordhi
.endscope
.endmacro

.macro DETECT_COLLISION PLAYER, OTHER
.scope
	; can only collide while dashing
	LDA PLAYER + Player::dash_cooldown
	CMP #0
	BEQ no_collision

	; can't collide if we have lower cooldown than them
	CMP OTHER + Player::dash_cooldown
	BCC no_collision

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

	; are we on the bottom side of the top bounds of enemy?
	LDA PLAYER + Player::pos + Vector2::ycoordhi
	CMP OTHER  + Player::pos + Vector2::ycoordhi
	BCC no_collision

	; are we on the top side of the bottom bounds of enemy?
	; i e, are we horizontally inside their bounding box?
	LDA OTHER + Player::pos + Vector2::ycoordhi
	CLC
	ADC #8 ; height of player?
	CMP PLAYER + Player::pos + Vector2::ycoordhi
	BCC no_collision

; HIT! Give enemy our velocity
	LDA PLAYER + Player::vel + Vector1::xcoord
	STA OTHER  + Player::vel + Vector1::xcoord
	LDA #0
	STA PLAYER + Player::vel + Vector1::xcoord

	LDA #SND_HIT
	LDX #FAMISTUDIO_SFX_CH1
	JSR AUDIO_PLAY_SFX

	; sometimes we get stuck? push player away from us once maybe
	MOVEMENT_PHYSICS_XY OTHER
	

no_collision:
.endscope
.endmacro

DO_PHYSICS:
	MOVEMENT_PHYSICS_BASE player_1
	MOVEMENT_PHYSICS_BASE player_2
	; movement_physics is called so many times because character is moving too slow
	; and my subpixel movement code sucks. This is a hack to speed up char movement.
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_1
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2
	MOVEMENT_PHYSICS_XY player_2



	DETECT_COLLISION player_1, player_2
	DETECT_COLLISION player_2, player_1

	RTS



; ------ fire handling

MOVE_FIRE:
	LDX fire_move_counter
	INX
	STX fire_move_counter
	CPX #20
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

.macro IS_PLAYER_DEAD	PLAYER, ENEMY
.scope
	IS_PLAYER_IN_LEFT_FIRE PLAYER
	IS_PLAYER_IN_RIGHT_FIRE PLAYER

	LDA PLAYER + Player::dead
	CMP #1
	BNE no_win
	INC ENEMY + Player::score

	LDA #SND_BURN
	LDX #FAMISTUDIO_SFX_CH0
	JSR AUDIO_PLAY_SFX

no_win:
.endscope
.endmacro

HANDLE_WIN_STATE:
	LDX winner
	CPX #0
	BEQ no_winner_yet
	LDX win_screen_counter
	INX
	STX win_screen_counter
	
	CPX #100
	BNE not_win_screen_yet
	LDX #Scenes::win
	STX wanted_scene
not_win_screen_yet:

	LDX win_palette_index
	INX
	STX win_palette_index
	LDX win_palette_index
	CPX #2
	BNE skip_palette_reset
	LDX #$00
	STX win_palette_index
	skip_palette_reset:
	no_winner_yet:

	RTS

EVALUATE_WINNING_CONDITION:
	IS_PLAYER_DEAD player_1, player_2
	IS_PLAYER_DEAD player_2, player_1

	LDA player_1 + Player::dead
	ADC player_2 + Player::dead
	
	CMP #0
	BEQ no_winner
		LDX winner
		INX
		STX winner
		LDX #$00
		STX player_1 + Player::dash_cooldown
		STX player_2 + Player::dash_cooldown
	no_winner:

	RTS


DRAW_LEVEL:
; Draw players
	DRAW_PLAYER player_1, mem_sprites,       $10, $01
	DRAW_PLAYER player_2, mem_sprites + 4*4, $14, $05

	JSR DRAW_BURNT_GROUND
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

DRAW_BURNT_GROUND:
	LDA fire_location_left
	LSR A
	LSR A
	LSR A
	LSR A
	TAY
	; A now contains index of left column to burn

 	bit $2002 ; reset ppu latch

	; figure out which column to burn
	CPY #1
	BEQ @col_1
	CPY #2
	BEQ @col_2
	; .. and so on

	JMP @done

@col_1:
	LDA #$23
	STA $2006
	LDA #$E0
	STA $2006
	LDA #%00101111
	STA $2007
	LDA #$23
	STA $2006
	LDA #$E8
	STA $2006
	LDA #%00100010
	STA $2007

	LDA #$23
	STA $2006
	LDA #$E7
	STA $2006
	LDA #%10001111
	STA $2007
	LDA #$23
	STA $2006
	LDA #$EF
	STA $2006
	LDA #%10001000
	STA $2007
	JMP @done
@col_2:
	LDA #$23
	STA $2006
	LDA #$E0
	STA $2006
	LDA #%10101111
	STA $2007
	LDA #$23
	STA $2006
	LDA #$E8
	STA $2006
	LDA #%10101010
	STA $2007

	LDA #$23
	STA $2006
	LDA #$E7
	STA $2006
	LDA #%10101111
	STA $2007
	LDA #$23
	STA $2006
	LDA #$EF
	STA $2006
	LDA #%10101010
	STA $2007
	JMP @done
@col_3:
@col_4:
@col_5:
@col_6:
@col_7:
@col_8:

@done:
	; must reset scroll after touching PPUADDR
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDA #$00
	STA $2005
	STA $2005

	RTS
