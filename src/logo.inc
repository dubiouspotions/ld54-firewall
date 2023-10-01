INITIALIZE_LOGO:

; write our first level to the first nametable
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00
load_logo_tilemap_p1:
	LDA logo_tilemap, X
	STA $2007
	INX
	CPX #0
	BNE load_logo_tilemap_p1
load_logo_tilemap_p2:
	LDA logo_tilemap+256, X
	STA $2007
	INX
	CPX #0
	BNE load_logo_tilemap_p2
load_logo_tilemap_p3:
	LDA logo_tilemap+512, X
	STA $2007
	INX
	CPX #0
	BNE load_logo_tilemap_p3
load_logo_tilemap_p4:
	LDA logo_tilemap+768, X
	STA $2007
	INX
	CPX #0
	BNE load_logo_tilemap_p4

; write our first level's palette data to the first nametable
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	LDX #$00
load_logo_tilemap_color:
	LDA logo_tilemap_palette, X
	STA $2007
	INX
	CPX #64
	BNE load_logo_tilemap_color
	
	RTS

UPDATE_LOGO:
  LDX logo_counter
  INX
  STX logo_counter
  CPX #100
  BNE continue_to_show_logo
  LDX #Scenes::mainmenu
  STX wanted_scene
  continue_to_show_logo:
	RTS


DRAW_LOGO:	
	RTS