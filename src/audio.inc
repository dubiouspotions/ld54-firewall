; https://irkenkitties.com/blog/2015/03/29/creating-sound-on-the-nes/
; https://nesdoug.com/2015/12/02/14-intro-to-sound/
; https://www.nesdev.org/wiki/APU
; https://www.nesdev.org/wiki/APU_basics
; https://forums.nesdev.org/viewtopic.php?f=2&t=20825&p=256016

; DDLC VVVV
; D : Duty cycle of the pulse wave 00 = 12.5% 01 = 25% 10 = 50% 11 = 75%
; L : Length Counter Halt
; C : Constant Volume
; V : 4-bit volume
mem_apu_pulse1_control = $4000
mem_apu_pulse2_control = $4004

; EPPP NSSS
; E : Enabled flag
; P : Sweep Divider Period
; N : Negate flag, inverts the sweep envelope
; S : Shift count
mem_apu_pulse1_ramp_control = $4001
mem_apu_pulse2_ramp_control = $4005

; TTTT TTTT
; T : Low 8 bits of the timer that controls the frequency
mem_apu_pulse1_ft = $4002
mem_apu_pulse2_ft = $4006

; LLLL LTTT
; L : Length counter, if Length Counter Halt is 0, timer for note length
; T : High 3 bits of timer that controls frequency
mem_apu_pulse1_ct = $4003
mem_apu_pulse2_ct = $4007

; Write: ---D NT21 	Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1) 
mem_apu_status = $4015


CLEAR_APU:
        ldy #$13
@loop:  lda @regs,y
        sta $4000,y
        dey
        bpl @loop
 
        ; We have to skip over $4014 (OAMDMA)
        lda #$0f
        sta $4015
        lda #$40
        sta $4017

    rts

@regs:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00

PLAY_BEEP:

    LDA #%10011111
    STA mem_apu_pulse1_control

    LDA #213
    STA mem_apu_pulse1_ft

    LDA #%11111000
    STA mem_apu_pulse1_ct
    
    LDA #%10011111
    STA mem_apu_pulse2_control

    LDA #180
    STA mem_apu_pulse2_ft

    LDA #%11111000
    STA mem_apu_pulse2_ct


    LDA #%00000011
    STA mem_apu_status

    rts