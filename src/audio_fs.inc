; Until I learn to code the NES APU: Use FamiStudio.

FAMISTUDIO_CFG_EXTERNAL       = 1
FAMISTUDIO_CFG_DPCM_SUPPORT   = 0
FAMISTUDIO_CFG_SFX_SUPPORT    = 1 
FAMISTUDIO_CFG_SFX_STREAMS    = 2
FAMISTUDIO_CFG_EQUALIZER      = 1
FAMISTUDIO_USE_VOLUME_TRACK   = 1
FAMISTUDIO_USE_PITCH_TRACK    = 1
FAMISTUDIO_USE_SLIDE_NOTES    = 1
FAMISTUDIO_USE_VIBRATO        = 1
FAMISTUDIO_USE_ARPEGGIO       = 1
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1
FAMISTUDIO_USE_RELEASE_NOTES  = 1
FAMISTUDIO_DPCM_OFF           = $e000


; CA65-specifc config.
.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE

.include "../deps/famistudio/famistudio_ca65.s"

AUDIO_INIT:
    sta $4015 ; disable APU sound
    sta $4010 ; disable DMC IRQ
    lda #$40
    sta $4017 ; disable APU IRQ

    lda #1 ; NTSC
    jsr famistudio_init

    ldx #<sounds
    ldy #>sounds
    jsr famistudio_sfx_init

    ldx #.lobyte(music_data_firewall)
    ldy #.hibyte(music_data_firewall)
    lda #1 ; NTSC
    jsr famistudio_init

    rts

AUDIO_NMI_UPDATE:
    jsr famistudio_update
    rts

; Index of song in A
AUDIO_START_MUSIC:
    jsr famistudio_music_play

    rts

; Index of sound in A
; Sound effects channel in X
AUDIO_PLAY_SFX:
	jsr famistudio_sfx_play

    rts
