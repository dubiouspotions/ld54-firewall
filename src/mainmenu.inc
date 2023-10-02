INITIALIZE_MAINMENU:

; write our first level to the first nametable
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00
load_mainmenu_tilemap_p1:
	LDA mainmenu_tilemap, X
	STA $2007
	INX
	CPX #0
	BNE load_mainmenu_tilemap_p1
load_mainmenu_tilemap_p2:
	LDA mainmenu_tilemap+256, X
	STA $2007
	INX
	CPX #0
	BNE load_mainmenu_tilemap_p2
load_mainmenu_tilemap_p3:
	LDA mainmenu_tilemap+512, X
	STA $2007
	INX
	CPX #0
	BNE load_mainmenu_tilemap_p3
load_mainmenu_tilemap_p4:
	LDA mainmenu_tilemap+768, X
	STA $2007
	INX
	CPX #0
	BNE load_mainmenu_tilemap_p4

; write our first level's palette data to the first nametable
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	LDX #$00
load_mainmenu_tilemap_color:
	LDA mainmenu_tilemap_palette, X
	STA $2007
	INX
	CPX #64
	BNE load_mainmenu_tilemap_color
	
	RTS

UPDATE_MAINMENU:
	RTS


DRAW_MAINMENU:	
	RTS