; This file is for the FamiStudio Sound Engine and was generated by FamiStudio

.if FAMISTUDIO_CFG_C_BINDINGS
.export _music_data_journey_to_silius=music_data_journey_to_silius
.endif

music_data_journey_to_silius:
	.byte 1
	.word @instruments
	.word @samples-4
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4 ; 00 : Title Screen
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0

.export music_data_journey_to_silius
.global FAMISTUDIO_DPCM_PTR

@instruments:
	.word @env2,@env8,@env10,@env4 ; 00 : LeadDuty0Buzz
	.word @env3,@env8,@env10,@env4 ; 01 : LeadDuty0Main
	.word @env13,@env8,@env10,@env0 ; 02 : LeadDuty0Outro
	.word @env9,@env8,@env10,@env0 ; 03 : LeadDuty0Plain
	.word @env3,@env8,@env14,@env4 ; 04 : LeadDuty1Main
	.word @env1,@env8,@env14,@env0 ; 05 : LeadDuty1Plain
	.word @env6,@env8,@env11,@env4 ; 06 : LeadDuty2Main
	.word @env9,@env8,@env11,@env0 ; 07 : LeadDuty2Plain
	.word @env7,@env15,@env10,@env0 ; 08 : NoiseTom1
	.word @env17,@env16,@env10,@env0 ; 09 : NoiseTom2
	.word @env7,@env16,@env10,@env0 ; 0a : NoiseTom3
	.word @env5,@env12,@env10,@env0 ; 0b : TriTomArp
	.word @env5,@env8,@env10,@env0 ; 0c : TriTomPlain

@env0:
	.byte $00,$c0,$7f,$00,$02
@env1:
	.byte $00,$c3,$7f,$00,$02
@env2:
	.byte $08,$ce,$cb,$ca,$c9,$c9,$00,$05,$c1,$c5,$c4,$c3,$c2,$c1,$00,$0d
@env3:
	.byte $0f,$c4,$c6,$c9,$c8,$0e,$c7,$0e,$c6,$0e,$c5,$0e,$c4,$00,$0c,$c1,$c5,$c4,$c3,$c2,$c1,$00,$14
@env4:
	.byte $00,$c0,$07,$c1,$c3,$c6,$c3,$c1,$bf,$bd,$ba,$bd,$bf,$00,$03
@env5:
	.byte $00,$cf,$7f,$00,$02
@env6:
	.byte $0e,$c5,$c6,$c6,$ca,$cb,$cc,$cb,$ca,$c9,$c8,$c7,$00,$0b,$c1,$c5,$c4,$c3,$c2,$c1,$00,$13
@env7:
	.byte $00,$cc,$cc,$c9,$c5,$c2,$c0,$00,$06
@env8:
	.byte $c0,$7f,$00,$01
@env9:
	.byte $00,$c4,$7f,$00,$02
@env10:
	.byte $7f,$00,$00
@env11:
	.byte $c2,$7f,$00,$00
@env12:
	.byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$00,$09
@env13:
	.byte $00,$c5,$c9,$c9,$c8,$00,$04
@env14:
	.byte $c1,$7f,$00,$00
@env15:
	.byte $c0,$c3,$00,$01
@env16:
	.byte $c0,$c6,$00,$01
@env17:
	.byte $00,$cd,$ce,$cc,$c8,$c9,$c7,$c6,$c4,$c3,$c1,$c0,$00,$0b
@env18:
	.byte $00,$c0,$be,$bc,$bc,$bd,$bf,$c1,$c3,$c4,$c4,$c2,$00,$01

@samples:
	.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$09,$40 ; 00 Sample 1 (Pitch:9)
	.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0a,$40 ; 01 Sample 1 (Pitch:10)
	.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0c,$40 ; 02 Sample 1 (Pitch:12)
	.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0e,$40 ; 03 Sample 1 (Pitch:14)
	.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0f,$40 ; 04 Sample 1 (Pitch:15)
	.byte $10+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$08,$40 ; 05 Sample 2 (Pitch:8)
	.byte $10+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$0a,$40 ; 06 Sample 2 (Pitch:10)
	.byte $10+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$0d,$40 ; 07 Sample 2 (Pitch:13)
	.byte $10+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$0e,$40 ; 08 Sample 2 (Pitch:14)
	.byte $20+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0d,$40 ; 09 Sample 3 (Pitch:13)
	.byte $20+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0e,$40 ; 0a Sample 3 (Pitch:14)
	.byte $30+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$0c,$40 ; 0b Sample 4 (Pitch:12)
	.byte $30+.lobyte(FAMISTUDIO_DPCM_PTR),$3e,$0f,$40 ; 0c Sample 4 (Pitch:15)
	.byte $40+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0a,$40 ; 0d Sample 5 (Pitch:10)
	.byte $40+.lobyte(FAMISTUDIO_DPCM_PTR),$3f,$0e,$40 ; 0e Sample 5 (Pitch:14)

@tempo_env_1_mid:
	.byte $03,$05,$80

@song0ch0:
	.byte $cf
@song0ch0loop:
	.byte $46, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $00, $a5, $8a, $19, $91, $1c, $91, $19, $91, $1e, $1f, $81
	.byte $20, $9f, $1e, $91
@song0ref22:
	.byte $82, $14, $af, $44, $87, $16
@song0ref28:
	.byte $d7, $44, $87, $47, $00, $a5, $8a, $19, $91, $1c, $91, $19, $91, $1e, $1f, $81, $20, $9f, $1e, $91, $82, $20, $af, $44
	.byte $87, $1e
	.byte $41, $12
	.word @song0ref28
	.byte $41, $1c
	.word @song0ref22
	.byte $d7, $44, $87
@song0ref63:
	.byte $47, $a7, $17, $91, $44, $91, $16, $87, $44, $87, $17, $91, $44, $91, $17, $a5, $44, $91, $16, $91, $44, $91, $16, $87
	.byte $44, $87, $17, $87, $44, $af
	.byte $41, $1d
	.word @song0ref63
	.byte $41, $1d
	.word @song0ref63
	.byte $47, $a7, $17, $91, $44, $91, $16, $87, $44, $87, $17, $91, $44, $91, $14, $ff, $93, $44, $87, $8c
@song0ref119:
	.byte $19, $91, $47, $89, $44, $87, $19, $87, $44, $87, $1c, $87, $44, $87, $19, $87, $44, $87, $1e, $87, $44, $87, $19, $91
	.byte $44, $91, $20, $9b, $44, $87
@song0ref149:
	.byte $19, $87, $44, $87, $1e, $87, $44, $87, $19, $87, $44, $87, $1c, $87, $44, $87, $19, $91, $44, $91, $14, $91, $47, $89
	.byte $44, $87, $14, $87, $44, $87, $17, $87, $44, $87, $14, $87, $44, $87, $17, $87, $44, $87, $1a, $43, $1b, $81, $43, $1c
	.byte $8b, $1b, $87, $44, $87, $19, $ff, $93, $44, $87
	.byte $41, $19
	.word @song0ref119
	.byte $1e, $43, $1f, $81, $43, $20, $9f
	.byte $41, $21
	.word @song0ref149
	.byte $19, $87, $44, $87, $1a, $43, $1b, $81, $43, $1c, $8b, $1b, $87, $44, $87, $17, $87, $44, $87, $19, $ff, $a7, $44, $87
	.byte $47
@song0ref245:
	.byte $1e, $81, $43, $1f, $81, $43, $20, $d9, $1e, $87, $44, $87, $1c, $87, $44, $87, $1b, $d7, $44, $87, $1c, $91, $44, $87
	.byte $1e, $91, $44, $87, $1e, $43, $1f, $81, $43, $20, $8b, $47, $ff, $8b, $88, $1e, $43, $1f, $81, $43, $20, $9f, $1e, $43
	.byte $1f, $81, $43, $20, $8b, $22, $91, $44, $91, $23, $9b, $44, $af, $47, $8c
	.byte $41, $1a
	.word @song0ref245
	.byte $19, $91, $47, $ff, $b3, $80, $19, $87, $44, $87, $19, $87, $44, $87, $19, $87, $44, $87, $19, $87, $44, $c3, $47, $82
@song0ref335:
	.byte $19, $c3, $44, $87, $19, $c3, $44, $87, $19, $af, $44, $87, $19, $cd, $44, $91, $47
	.byte $41, $10
	.word @song0ref335
	.byte $47
	.byte $41, $10
	.word @song0ref335
	.byte $47, $1b, $c3, $44, $87, $1b, $c3, $44, $87, $1b, $af, $44, $87, $1b, $cd, $44, $91, $47, $19, $9b, $44, $87, $19, $9b
	.byte $44, $87, $19, $91, $44, $87, $19, $91, $44, $87, $19
@song0ref394:
	.byte $af, $44, $87, $19, $9b, $44, $87, $19, $91, $44, $87, $19, $91
@song0ref407:
	.byte $44, $87, $19, $91, $47, $9d, $44, $87, $19, $9b, $44, $87, $19, $91, $44, $87, $19, $91, $44, $87, $19, $c3, $44, $87
	.byte $17, $c3
	.byte $41, $14
	.word @song0ref407
	.byte $41, $18
	.word @song0ref394
	.byte $1b, $91, $44, $87, $20, $91, $44, $87, $20, $ff, $a7, $44, $87, $47, $00, $a5, $86
@song0ref456:
	.byte $19, $91, $1b, $91
@song0ref460:
	.byte $1c, $91, $1e, $91, $19, $91, $1b, $91, $1c, $91, $1e, $91, $19, $91, $1b, $91, $1c, $91, $1e, $91, $19, $91, $1b, $91
	.byte $47
	.byte $41, $18
	.word @song0ref460
	.byte $1c, $91, $1e, $91, $19, $91, $1b, $91, $47
	.byte $41, $14
	.word @song0ref460
	.byte $1b, $91, $1c, $91, $1e, $91, $20, $b9, $47, $23, $91, $25, $a5
@song0ref513:
	.byte $27, $91, $28, $91, $2a, $91, $25, $91, $27, $91, $28, $91, $2a, $a5, $2c, $91, $2d, $91, $2f, $91, $2a, $91, $2c, $91
	.byte $47, $2d, $91, $2f, $91, $31, $ff, $ed, $43, $4f, $05, $3d, $37, $a5, $42
	.word @song0ch0loop
@song0ch1:
	.byte $cf
@song0ch1loop:
	.byte $88
@song0ref557:
	.byte $19, $87, $44, $87, $1c, $87, $44, $87, $19, $87, $44, $87, $1e, $43, $1f, $81, $43, $20, $9f, $1e, $87, $44, $87, $1c
	.byte $9b, $44, $87, $17, $af, $44, $87, $19, $d7, $44, $87
	.byte $41, $19
	.word @song0ref557
	.byte $23, $af, $44, $87, $22, $d7, $44, $87
	.byte $41, $21
	.word @song0ref557
	.byte $41, $19
	.word @song0ref557
	.byte $23, $af, $44, $87, $22, $d7, $44, $87, $a7, $82
@song0ref619:
	.byte $1c, $91, $44, $91, $1b, $87, $44, $87, $1c, $91, $44, $91, $1c, $a5, $44, $91, $1b, $91, $44, $91, $1b, $87, $44, $87
	.byte $1c, $87, $44, $af, $a7
	.byte $41, $1d
	.word @song0ref619
	.byte $41, $1d
	.word @song0ref619
	.byte $1c, $91, $44, $91, $1b, $87, $44, $87, $1c, $91, $44, $91, $1b, $ff, $a7, $44, $87, $93, $8e, $19, $b9, $1c, $91, $19
	.byte $91, $1e, $91, $19, $a5, $20, $a5, $19, $91, $1e, $91, $19, $91, $1c, $91, $19, $91, $93, $14, $b9, $17, $91, $14, $91
	.byte $17, $91, $1a, $1b, $81, $1c, $8b, $1b, $91, $19, $ff, $89, $cf, $1c, $91, $19, $91, $1e, $91, $19, $a5, $1e, $1f, $81
	.byte $20, $9f, $19, $91, $1e, $91, $19, $91, $1c, $91, $19, $91, $93, $14, $b9, $17, $91, $19, $91, $1a, $1b, $81, $1c, $8b
	.byte $1b, $91, $17, $91, $19, $ff, $89, $a7
@song0ref758:
	.byte $1e, $81, $1f, $81, $20, $d9, $1e, $91, $1c, $91, $1b, $e1, $1c, $9b, $1e, $87, $95, $1f, $81, $20, $ef, $82, $1b, $9b
	.byte $44, $87, $1b, $87, $44, $87, $1e, $91, $44, $91, $20, $9b, $44, $af, $a7, $8e
	.byte $41, $10
	.word @song0ref758
	.byte $93, $19, $ff, $9d, $80, $14, $87, $44, $87, $14, $87, $44, $87, $14, $87, $44, $87, $14, $87, $44, $c3, $88
@song0ref823:
	.byte $20, $c3, $44, $87, $1e, $c3, $44, $87, $1c, $af, $44, $87, $1e, $cd, $44, $91
	.byte $41, $10
	.word @song0ref823
	.byte $41, $10
	.word @song0ref823
	.byte $21, $c3, $44, $87, $20, $c3, $44, $87, $1e, $af, $44, $87, $20, $cd, $44, $91, $20, $9b, $44, $87, $1e, $9b, $44, $87
	.byte $1c, $91, $44, $87, $1e, $91, $44, $87
@song0ref877:
	.byte $20, $af, $44, $87, $1e, $9b, $44, $87, $1c, $91, $44, $87, $1e, $91
@song0ref891:
	.byte $44, $87, $20, $91, $9d, $44, $87, $1e, $9b, $44, $87, $1c, $91, $44, $87, $1e, $91, $44, $87, $1c, $c3, $44, $87, $1b
	.byte $c3
	.byte $41, $13
	.word @song0ref891
	.byte $41, $19
	.word @song0ref877
	.byte $20, $91, $44, $87, $23, $91, $44, $87, $25, $ff, $a7, $44, $87, $84
	.byte $41, $1c
	.word @song0ref456
	.byte $41, $18
	.word @song0ref460
	.byte $41, $18
	.word @song0ref460
	.byte $1c, $91, $1e, $91, $1b, $91, $1c, $91, $1e, $91, $20, $b9, $23, $91, $25, $91, $93
	.byte $41, $18
	.word @song0ref513
	.byte $2d, $91, $2f, $91, $31, $cd, $48, .lobyte(@env18), .hibyte(@env18), $ff, $9d, $48, .lobyte(@env0), .hibyte(@env0)
	.byte $49, $81, $43, $4f, $06, $3d, $30, $cd, $42
	.word @song0ch1loop
@song0ch2:
@song0ref990:
	.byte $98, $26, $25, $26, $81, $25, $26, $27, $26, $25, $26, $96, $26, $85, $00, $26, $85, $00, $1e, $85, $00, $1e, $85, $00
	.byte $1a, $8f, $00
@song0ch2loop:
	.byte $96
@song0ref1019:
	.byte $1c, $83, $00, $8b, $1c, $83, $00, $8b, $22, $8f, $00, $1c, $83, $00, $8b, $1c, $83, $00, $8b, $1c, $83, $00, $8b, $22
	.byte $8f, $00, $1c, $83, $00, $8b
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
@song0ref1055:
	.byte $26, $8f, $00, $26, $8f, $00, $1e, $8f, $00, $1a, $8f, $00, $26, $85, $00, $26, $85, $00, $89, $26, $85, $00, $1e, $85
	.byte $00, $1e, $85, $00, $1a, $8f, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
@song0ref1095:
	.byte $26, $85, $00, $26, $85, $00, $1e, $85, $00, $1a, $85, $00, $26, $85, $00, $1e, $85, $00, $1e, $85, $00, $1a, $85, $00
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1f
	.word @song0ref1055
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $18
	.word @song0ref1095
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1f
	.word @song0ref1055
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $18
	.word @song0ref1095
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1f
	.word @song0ref1055
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $1c, $83, $00, $8b, $22, $8f, $00, $22, $8f, $00, $22, $8f, $00, $22, $8f, $00, $95, $98, $22, $83, $00, $9d, $96
@song0ref1235:
	.byte $1c, $83, $00, $c7, $1c, $83, $00, $c7, $1c, $83, $00, $b3, $1c, $83, $00, $9f, $98, $22, $83, $00, $8b, $96, $1c, $83
	.byte $00, $9f
	.byte $41, $18
	.word @song0ref1235
	.byte $41, $18
	.word @song0ref1235
	.byte $41, $10
	.word @song0ref1235
	.byte $22, $8f, $00, $22, $8f, $00, $22, $8f, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1f
	.word @song0ref1055
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $18
	.word @song0ref1095
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1f
	.word @song0ref1055
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $18
	.word @song0ref1095
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00
	.byte $41, $1e
	.word @song0ref1019
	.byte $41, $18
	.word @song0ref1095
	.byte $41, $17
	.word @song0ref990
	.byte $85, $00, $1a, $85, $00, $42
	.word @song0ch2loop
@song0ch3:
	.byte $92, $1a, $83, $1a, $85, $1a, $83, $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87
@song0ch3loop:
@song0ref1380:
	.byte $90
@song0ref1381:
	.byte $10, $91, $10, $91, $92, $1a, $91, $90, $10, $91, $10, $91, $10, $91, $92, $1a, $91, $90, $10, $91
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
@song0ref1407:
	.byte $94, $1a, $91, $1a, $91, $1a, $91, $1a, $91, $1a, $87, $1a, $91, $1a, $87, $1a, $87, $1a, $87, $1a, $91
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
@song0ref1437:
	.byte $94
@song0ref1438:
	.byte $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87, $1a, $87
	.byte $41, $10
	.word @song0ref1438
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $14
	.word @song0ref1407
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1437
	.byte $41, $10
	.word @song0ref1438
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $14
	.word @song0ref1407
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1437
	.byte $41, $10
	.word @song0ref1438
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $14
	.word @song0ref1407
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $10, $91, $92, $1a, $91, $1a, $91, $1a, $91, $1a, $a7, $1a, $a3, $90
@song0ref1546:
	.byte $10, $cd, $10, $cd, $10, $b9, $10, $a5, $92, $1a, $91, $90, $10, $a5, $10, $cd, $10, $cd, $10, $b9, $10, $a5, $92, $1a
	.byte $91, $90, $10, $a5
	.byte $41, $16
	.word @song0ref1546
	.byte $1a, $91, $1a, $91
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $14
	.word @song0ref1407
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1437
	.byte $41, $10
	.word @song0ref1438
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $14
	.word @song0ref1407
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1381
	.byte $41, $10
	.word @song0ref1437
	.byte $41, $10
	.word @song0ref1438
	.byte $41, $10
	.word @song0ref1380
	.byte $41, $10
	.word @song0ref1437
	.byte $41, $10
	.word @song0ref1438
	.byte $42
	.word @song0ch3loop
@song0ch4:
	.byte $cf
@song0ch4loop:
@song0ref1649:
	.byte $03, $91
@song0ref1651:
	.byte $03, $91, $03, $91, $03, $91, $03, $91, $03, $91, $03, $91, $03, $91, $02, $91, $02, $91, $04, $91, $01, $91, $01, $91
	.byte $08, $91, $01, $91, $08, $91
	.byte $41, $10
	.word @song0ref1649
@song0ref1684:
	.byte $06, $91, $06, $91, $0a, $91, $01, $91, $01, $91, $08, $91, $01, $91, $08, $91
	.byte $41, $20
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1684
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $10
	.word @song0ref1649
	.byte $41, $12
	.word @song0ref1651
	.byte $02, $91, $02, $91, $02, $91, $02, $91, $02, $91, $02, $91, $02
@song0ref1743:
	.byte $91, $03, $91, $03, $91, $03, $91, $05, $91, $03, $91, $05, $91, $03, $91, $03, $91, $0c, $91, $0d, $91, $0c, $91, $0c
	.byte $91, $0c, $91, $0d, $91, $0c, $91, $0c, $91, $02, $91, $02, $91, $02, $91, $04, $91, $0c, $91, $0d, $91, $0c, $91, $0c
	.byte $91, $03, $91, $05, $91, $03, $91, $03, $91, $03, $91, $05, $91, $03, $91, $03
	.byte $41, $40
	.word @song0ref1743
@song0ref1810:
	.byte $91, $01, $91, $01, $91, $08, $91, $01, $91, $01, $91, $01, $91, $08, $91, $01, $91, $02, $91, $02, $91, $04, $91, $02
	.byte $91, $02, $91, $02, $91, $04, $91, $02, $91, $03, $91, $03, $91, $05, $91, $03, $91, $05, $91, $03, $91, $03, $91, $05
@song0ref1858:
	.byte $91, $03, $91, $03, $91, $05, $91, $03, $91, $03, $91, $05, $91, $03, $91, $05
	.byte $41, $35
	.word @song0ref1810
	.byte $03, $91, $03, $91, $03, $cd, $03, $cd, $03, $cd, $03, $b9, $03, $a5, $03, $91, $05, $91, $03, $91, $0c, $cd, $0c, $cd
	.byte $0c, $b9, $0c, $a5, $0c, $91, $0d, $91, $0c, $91, $07, $cd, $07, $cd, $07, $b9, $07, $a5, $07, $91, $0d, $91, $07, $91
	.byte $0c, $cd, $0c, $cd, $0c, $b9, $0c, $a5, $0d, $91, $0c, $91, $0d
	.byte $41, $10
	.word @song0ref1858
@song0ref1941:
	.byte $91, $0c, $91, $0c, $91, $0d, $91, $0c, $91, $0c, $91, $0d, $91, $0c, $91, $0d, $91, $07, $91, $07, $91, $09, $91, $07
	.byte $91, $07, $91, $09, $91, $07, $91, $09
	.byte $41, $11
	.word @song0ref1941
	.byte $03, $91, $03, $91, $05, $91, $03, $91, $03, $91, $05, $91, $03, $91, $05
	.byte $41, $20
	.word @song0ref1941
	.byte $41, $10
	.word @song0ref1858
@song0ref1997:
	.byte $91, $03, $91, $03, $91, $03, $91, $05, $91, $03, $91, $03, $91, $0d, $91, $05, $91, $0c, $91, $0c, $91, $0c, $91, $0d
	.byte $91, $0c, $91, $0c, $91, $09, $91, $0d, $91, $0e, $91, $0e, $91, $0e, $91, $0f, $91, $0e, $91, $0e, $91, $02, $91, $0f
	.byte $91, $07, $91, $07, $91, $07, $91, $09, $91, $07, $91, $07, $91, $0b, $91, $09
	.byte $41, $40
	.word @song0ref1997
	.byte $41, $11
	.word @song0ref1997
	.byte $03, $91, $03, $91, $05, $91, $03, $91, $03, $91, $05, $91, $03, $91, $05, $91, $42
	.word @song0ch4loop