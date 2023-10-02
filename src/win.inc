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
	RTS