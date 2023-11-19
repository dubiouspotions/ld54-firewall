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

	; Hide gameplay stuff
	CLC
	LDY #$00
	LDA mem_fire_sprites
	@hide_fire_sprites:
		LDA #$F1
		STA mem_fire_sprites, Y
		INY
		INY
		INY
		INY
		CPY #128
		BNE @hide_fire_sprites
	LDX #$F1
	STX player_1 + Player::pos + Vector2::ycoordhi
	STX player_2 + Player::pos + Vector2::ycoordhi

	LDA #0
	JSR AUDIO_START_MUSIC

	LDA #0
	STA player_1 + Player::score
	STA player_2 + Player::score

	RTS

UPDATE_MAINMENU:
	LDA player_1 + Player::buttons_pressed
	AND #BTN_START
	BNE start_game

	LDA player_2 + Player::buttons_pressed
	AND #BTN_START
	BNE start_game

	LDA player_2 + Player::buttons_pressed
	AND #BTN_A
	BNE activate_p2
	RTS

activate_p2:
	LDX #1
	STX p2_is_human
	LDA #0
	STA player_2 + Player::buttons_pressed
	STA player_2 + Player::buttons

	LDA #SND_P2_JOINED
	LDX #FAMISTUDIO_SFX_CH0
	JSR AUDIO_PLAY_SFX

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
	LDA p2_is_human
	CMP #0
	BEQ p2_isnt_human

	; replace text under player 2
	LDX #$22
	STX $2006
	LDX #$F2
	STX $2006
	
	LDX #$DF
	STX $2007
	STX $2007
	LDX #$45
	STX $2007
	LDX #$DF
	STX $2007
	LDX #$EB
	STX $2007
	LDX #$EC
	STX $2007
	LDX #$DF
	STX $2007
	STX $2007
	STX $2007
	STX $2007

	; WHY do I have to reset scroll after modifying tilemap??
	LDA #$00
	STA $2005
	STA $2005

p2_isnt_human:

	DRAW_PLAYER player_1, mem_sprites, 		 $10, $01
	DRAW_PLAYER player_2, mem_sprites + 4*4, $14, $05
	RTS
