.macro MOVE_TO_WIN_POSITION	PLAYER
.scope
	LDX #120
	STX PLAYER + Player::pos + Vector2::xcoordhi
	LDX #$63
	STX PLAYER + Player::pos + Vector2::ycoordhi
.endscope
.endmacro

.macro HIDE_PLAYER	PLAYER
.scope
	LDX #$F1
	STX PLAYER + Player::pos + Vector2::ycoordhi
.endscope
.endmacro

INITIALIZE_WIN:

; write our win screen to the first nametable
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00
load_win_tilemap_p1:
	LDA win_tilemap, X
	STA $2007
	INX
	CPX #0
	BNE load_win_tilemap_p1
load_win_tilemap_p2:
	LDA win_tilemap+256, X
	STA $2007
	INX
	CPX #0
	BNE load_win_tilemap_p2
load_win_tilemap_p3:
	LDA win_tilemap+512, X
	STA $2007
	INX
	CPX #0
	BNE load_win_tilemap_p3
load_win_tilemap_p4:
	LDA win_tilemap+768, X
	STA $2007
	INX
	CPX #0
	BNE load_win_tilemap_p4

; write our first level's palette data to the first nametable
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	LDX #$00
load_win_tilemap_color:
	LDA win_tilemap_palette, X
	STA $2007
	INX
	CPX #64
	BNE load_win_tilemap_color
	
; Draw scores on screen
	LDX #$20
	STX $2006
	LDX #$E6
	STX $2006
	LDA player_1 + Player::score
	JSR PRINT_NUM
	
	LDX #$20
	STX $2006
	LDX #$F8
	STX $2006
	LDA player_2 + Player::score
	JSR PRINT_NUM

	

; Hide gameplay stuff
	CLC
	LDY #$00
	LDA mem_fire_sprites
	hide_fire_sprites:
		LDA #$F1
		STA mem_fire_sprites, Y
		INY
		INY
		INY
		INY
		CPY #128
		BNE hide_fire_sprites

	LDX player_1 + Player::dead
	CPX #0
	BEQ player_1_not_dead
		MOVE_TO_WIN_POSITION player_2
		HIDE_PLAYER player_1
	player_1_not_dead:

	LDX player_2 + Player::dead
	CPX #0
	BEQ player_2_not_dead
		MOVE_TO_WIN_POSITION player_1
		HIDE_PLAYER player_2
	player_2_not_dead:

	RTS


UPDATE_WIN:
  LDA player_1 + Player::buttons
	AND #BTN_START
	BNE restart_game
	LDA player_2 + Player::buttons
	AND #BTN_START
	BNE restart_game
	RTS

restart_game:
	; TODO: blink the arrows or something!
	LDA #Scenes::level
	STA wanted_scene

	RTS

DRAW_WIN:	
	DRAW_PLAYER player_1, mem_sprites, 		 $10, $01
	DRAW_PLAYER player_2, mem_sprites + 4*4, $14, $05
	RTS