.macro MOVE_TO_WIN_POSITION	PLAYER
.scope
	LDX #120
	STX PLAYER + Player::pos + Vector2::xcoordhi
	LDX #$63
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
	
	CLC
	LDY #$00
	LDA mem_fire_sprites
	hide_fire_sprites:
		LDA $F1
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
	player_1_not_dead:

	LDX player_2 + Player::dead
	CPX #0
	BEQ player_2_not_dead
		MOVE_TO_WIN_POSITION player_1
	player_2_not_dead:

	RTS


UPDATE_WIN:
  LDX win_scene_counter
  INX
  STX win_scene_counter
  CPX #200
  BNE continue_to_show_win
  LDX #Scenes::level
  STX wanted_scene
  continue_to_show_win:
	RTS


DRAW_WIN:	
	DRAW_PLAYER player_1, mem_sprites
	DRAW_PLAYER player_2, mem_sprites + 4*4
	RTS