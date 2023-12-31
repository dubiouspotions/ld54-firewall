; This file is for the FamiStudio Sound Engine and was generated by FamiStudio

.if FAMISTUDIO_CFG_C_BINDINGS
.export _music_data_firewall=music_data_firewall
.endif

music_data_firewall:
	.byte 2
	.word @instruments
	.word @samples-4
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4 ; 00 : WallOfFire
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
	.word @song1ch0,@song1ch1,@song1ch2,@song1ch3,@song1ch4 ; 01 : FireStarted
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0

.export music_data_firewall
.global FAMISTUDIO_DPCM_PTR

@instruments:
	.word @env7,@env3,@env6,@env0 ; 00 : Base
	.word @env2,@env3,@env5,@env0 ; 01 : dRUM
	.word @env4,@env3,@env6,@env0 ; 02 : Lead
	.word @env1,@env3,@env6,@env0 ; 03 : Lead2

@env0:
	.byte $00,$c0,$7f,$00,$02
@env1:
	.byte $00,$c2,$c3,$c4,$c7,$c9,$cc,$cf,$cc,$c9,$00,$09
@env2:
	.byte $00,$c1,$c4,$c2,$c0,$00,$04
@env3:
	.byte $c0,$7f,$00,$01
@env4:
	.byte $00,$c4,$c2,$c2,$c4,$c5,$c4,$c3,$c5,$c6,$00,$03
@env5:
	.byte $7f,$00,$00
@env6:
	.byte $c2,$7f,$00,$00
@env7:
	.byte $00,$c3,$c6,$c5,$c8,$cd,$cd,$ca,$c8,$c6,$c7,$c6,$c3,$c2,$c1,$c0,$00,$0f

@samples:

@tempo_env_1_mid:
	.byte $03,$05,$80

@song0ch0:
@song0ch0loop:
	.byte $46, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $84
@song0ref6:
	.byte $25, $85, $19, $83, $27, $83, $1b, $85, $28, $85
@song0ref16:
	.byte $1c, $28, $81, $1c, $81, $28, $1c, $81, $28, $81, $1c, $81, $28, $81, $1c, $28, $81, $00, $a7, $28, $85, $1c, $83, $2a
	.byte $83, $1e, $85, $2c, $85, $20, $2c, $81, $20, $81, $2c, $20, $81, $2c, $81, $20, $81, $2c, $81, $20, $2c, $81, $00, $a7
	.byte $47, $25, $85, $19, $83, $27, $83, $1b, $85, $80, $2b, $85, $84
	.byte $41, $12
	.word @song0ref16
	.byte $ff, $97, $47
	.byte $41, $44
	.word @song0ref6
	.byte $84
	.byte $41, $12
	.word @song0ref16
	.byte $ff, $97, $47
	.byte $41, $44
	.word @song0ref6
	.byte $84
	.byte $41, $12
	.word @song0ref16
	.byte $ff, $97, $47
	.byte $41, $44
	.word @song0ref6
	.byte $84
	.byte $41, $12
	.word @song0ref16
	.byte $ff, $97, $42
	.word @song0ch0loop
@song0ch1:
@song0ch1loop:
	.byte $86
@song0ref117:
	.byte $19, $b5, $00, $99, $1c, $99, $20, $99, $00, $99, $25, $8b, $25, $8b, $00, $99, $23, $8b, $21, $8b, $23, $c3, $00, $fb
	.byte $19, $b5, $00, $99, $1c, $99, $20, $99, $00, $99, $25, $99, $00, $99, $28, $d1, $00, $ff, $89
	.byte $41, $15
	.word @song0ref117
	.byte $8b, $23, $8b, $23, $8b, $00, $ff, $97, $20, $8b, $1e, $8b, $20, $8b, $20, $8b, $20, $8b, $00, $ff, $97, $20, $8b, $1e
	.byte $8b, $20, $b5, $00, $99, $19, $8b, $17, $8b, $19, $b5, $00, $99, $42
	.word @song0ch1loop
@song0ch2:
@song0ch2loop:
	.byte $80
@song0ref205:
	.byte $19, $99, $20, $85, $14, $83, $19, $b5, $00, $8b, $19, $85, $00, $83, $19, $c3, $00, $8b, $19, $83, $00, $85, $10, $99
	.byte $17, $85, $0b, $83, $10, $b5, $00, $8b, $10, $85, $00, $83, $10, $c3, $00, $8b, $10, $83, $00, $85
	.byte $41, $16
	.word @song0ref205
	.byte $1c, $99, $23, $85, $17, $83, $1c, $83, $00, $bd, $1c, $85, $00, $83, $1c, $c3, $00, $8b, $1c, $83, $00, $85
	.byte $41, $2c
	.word @song0ref205
	.byte $0f, $99, $16, $85, $0a, $83, $0f, $83, $00, $bd, $0f, $85, $00, $83, $0f, $c3, $00, $8b, $0f, $83, $00, $85, $0e, $99
	.byte $15, $85, $09, $83, $0e, $83, $00, $bd, $0e, $85, $00, $83, $0e, $c3, $00, $8b, $0e, $83, $00, $85, $42
	.word @song0ch2loop
@song0ch3:
@song0ch3loop:
	.byte $82
@song0ref326:
	.byte $24, $8b, $20, $8b, $20, $8b, $20, $8b, $2c, $8b, $20, $8b, $20, $8b, $20, $8b, $24, $8b, $20, $8b, $24, $8b, $20, $8b
	.byte $2c, $8b, $20, $8b, $20, $8b, $20, $8b
	.byte $41, $20
	.word @song0ref326
	.byte $41, $20
	.word @song0ref326
	.byte $41, $10
	.word @song0ref326
@song0ref367:
	.byte $00, $8b, $20, $8b, $2c, $8b, $20, $8b, $2c, $8b, $20, $8b, $2c, $8b, $20, $8b
	.byte $41, $20
	.word @song0ref326
	.byte $41, $20
	.word @song0ref326
	.byte $41, $20
	.word @song0ref326
	.byte $41, $10
	.word @song0ref326
	.byte $41, $10
	.word @song0ref367
	.byte $42
	.word @song0ch3loop
@song0ch4:
@song0ch4loop:
	.byte $ff, $df, $ff, $df, $ff, $df, $ff, $df, $ff, $df, $ff, $df, $ff, $df, $ff, $df, $42
	.word @song0ch4loop
@song1ch0:
@song1ch0loop:
	.byte $46, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid)
@song1ref5:
	.byte $ff, $df, $47, $ff, $df, $47, $ff, $df, $47, $ff, $df, $47
	.byte $41, $08
	.word @song1ref5
	.byte $42
	.word @song1ch0loop
@song1ch1:
@song1ch1loop:
	.byte $81, $84, $19, $db, $00, $ed, $14, $8b, $00
@song1ref33:
	.byte $1a, $f5, $00, $e5
@song1ref37:
	.byte $81, $19, $db, $00, $ed, $14, $8b, $00, $1c, $ff, $a9, $00, $b1
	.byte $41, $08
	.word @song1ref37
	.byte $41, $11
	.word @song1ref33
	.byte $42
	.word @song1ch1loop
@song1ch2:
@song1ch2loop:
	.byte $80
@song1ref61:
	.byte $19, $99, $00, $d1, $19, $85, $00, $83, $19, $99, $00, $b5, $19, $83, $00, $85, $10, $99, $00, $d1, $10, $85, $00, $83
	.byte $10, $a7, $00, $a7, $10, $83, $00, $85
	.byte $41, $10
	.word @song1ref61
	.byte $1c, $99, $00, $d1, $1c, $85, $00, $83, $1c, $99, $00, $b5, $1c, $83, $00, $85
	.byte $41, $20
	.word @song1ref61
	.byte $0f, $99, $00, $d1, $0f, $85, $00, $83, $0f, $a7, $00, $a7, $0f, $83, $00, $85, $0e, $99, $00, $d1, $0e, $85, $00, $83
	.byte $0e, $99, $00, $b5, $0e, $83, $00, $85, $42
	.word @song1ch2loop
@song1ch3:
@song1ch3loop:
	.byte $82
@song1ref152:
	.byte $24, $8b, $00, $8b, $20, $8b, $00, $8b, $2c, $8b, $00, $8b, $20, $8b, $00, $8b, $24, $8b, $20, $8b, $24
@song1ref173:
	.byte $8b, $20, $8b, $2c, $8b, $20, $8b, $00, $8b, $20, $8b
	.byte $41, $20
	.word @song1ref152
	.byte $41, $20
	.word @song1ref152
	.byte $24, $8b, $20, $8b, $00
	.byte $41, $0b
	.word @song1ref173
@song1ref198:
	.byte $00, $8b, $20, $8b, $2c, $8b, $00, $8b, $2c, $8b, $00, $8b, $2c, $8b, $20, $8b
	.byte $41, $20
	.word @song1ref152
	.byte $41, $20
	.word @song1ref152
	.byte $41, $20
	.word @song1ref152
	.byte $24, $8b, $20, $8b, $00
	.byte $41, $0b
	.word @song1ref173
	.byte $41, $10
	.word @song1ref198
	.byte $42
	.word @song1ch3loop
@song1ch4:
@song1ch4loop:
@song1ref238:
	.byte $ff, $df, $ff, $df, $ff, $df, $ff, $df
	.byte $41, $08
	.word @song1ref238
	.byte $42
	.word @song1ch4loop
