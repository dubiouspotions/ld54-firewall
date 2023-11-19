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

	LDA #0
	JSR AUDIO_START_MUSIC
	LDX p2_cpu
	INX
	STX p2_cpu
	RTS

UPDATE_MAINMENU:
	LDA player_1 + Player::buttons
	AND #BTN_START
	BNE start_game
	LDA player_2 + Player::buttons
	AND #BTN_START
	BNE start_game

	RTS
start_game:
	LDA #SND_START
	LDX #FAMISTUDIO_SFX_CH0
	JSR AUDIO_PLAY_SFX

	; TODO: blink the arrows or something!
	LDA #Scenes::level
	STA wanted_scene

	RTS


DRAW_MAINMENU:	
	RTS
