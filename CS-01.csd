<Cabbage>
form caption("CS-01") size(800, 420), guiMode("queue"), colour(10,10,10), pluginId("cs01")

; -----------------------------------------------------
; LOGO & LABELS
; -----------------------------------------------------
image bounds(10, 350, 120, 60), file("Images/ClovermindLogo.png")
label bounds(140, 360, 200, 20), text("CS-01"), fontColour(240, 120, 60)
label bounds(140, 380, 200, 20), text("Christopher Grehan"), fontColour(210,210,210)
label bounds(140, 400, 200, 20), text("Clovermind Music LLC"), fontColour(210,210,210)

; -----------------------------------------------------
; KEYBOARD
; -----------------------------------------------------
keyboard bounds(10, 260, 780, 80)

; -----------------------------------------------------
; OSCILLATOR
; -----------------------------------------------------
groupbox bounds(10,10,240,120), text("Oscillator"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

label bounds(20, 30, 80, 18), text("Waveform"), fontColour(230,230,230)
combobox bounds(20, 50, 100, 22), channel("waveform"), items("Saw")

rslider bounds(130, 30, 50, 70), channel("oscMix"), range(0,1,0.5,1,0.01), text("Mix")
rslider bounds(190, 30, 50, 70), channel("detune"), range(0,20,5,1,0.1), text("Detune")

; -----------------------------------------------------
; FILTER SECTION
; -----------------------------------------------------
groupbox bounds(260,10,240,120), text("Filter"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

rslider bounds(270,30,50,70), channel("cutoff"), range(50,18000,4000,0.3,1), text("Cutoff")
rslider bounds(330,30,50,70), channel("resonance"), range(0.1,1,0.4,1,0.01), text("Res")
rslider bounds(390,30,50,70), channel("filtEnvAmt"), range(0,1,0.5,1,0.01), text("EnvAmt")

; -----------------------------------------------------
; LFO SECTION
; -----------------------------------------------------
groupbox bounds(510,10,280,120), text("LFO"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

rslider bounds(520,30,60,70), channel("lfoRate"), range(0.01,10,1,0.5,0.01), text("Rate")
rslider bounds(590,30,60,70), channel("lfoDepth"), range(0,1,0,1,0.01), text("Depth")
combobox bounds(660,50,120,22), channel("lfoTarget"), items("Off","Cutoff")

; -----------------------------------------------------
; AMP ENVELOPE
; -----------------------------------------------------
groupbox bounds(10,140,240,110), text("Amp Env"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

rslider bounds(20,160,50,70), channel("ampAtt"), range(0.001,2,0.01,0.4,0.001), text("A")
rslider bounds(80,160,50,70), channel("ampDec"), range(0.001,4,0.2,0.4,0.001), text("D")
rslider bounds(140,160,50,70), channel("ampSus"), range(0,1,0.7,1,0.01), text("S")
rslider bounds(200,160,50,70), channel("ampRel"), range(0.001,4,0.3,0.4,0.001), text("R")

; -----------------------------------------------------
; FILTER ENVELOPE
; -----------------------------------------------------
groupbox bounds(260,140,240,110), text("Filter Env"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

rslider bounds(270,160,50,70), channel("filtAtt"), range(0.001,4,0.01,0.4,0.001), text("A")
rslider bounds(330,160,50,70), channel("filtDec"), range(0.001,4,0.3,0.4,0.001), text("D")
rslider bounds(390,160,50,70), channel("filtSus"), range(0,1,0.5,1,0.01), text("S")
rslider bounds(450,160,50,70), channel("filtRel"), range(0.001,4,0.4,1,0.001), text("R")

; -----------------------------------------------------
; FX + MASTER
; -----------------------------------------------------
groupbox bounds(510,140,280,110), text("FX / Master"), colour(15,15,15), fontColour(255,120,60), outlineColour(255,80,40)

rslider bounds(520,160,50,70), channel("drive"), range(0,1,0.2,1,0.01), text("Drive")
rslider bounds(580,160,50,70), channel("chorusMix"), range(0,1,0,1,0.01), text("Chor")
rslider bounds(640,160,50,70), channel("delayMix"), range(0,1,0,1,0.01), text("Delay")
rslider bounds(700,160,50,70), channel("reverbMix"), range(0,1,0,1,0.01), text("Rev")

vslider bounds(770,10,20,240), channel("masterVol"), range(0,1.5,0.8,1,0.01), text("Vol")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-d -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5 -m0d
</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

massign 0, 1

opcode CentRatio, k, k
    kc xin
    xout exp(log(2) * kc / 1200)
endop

instr 1
    ;; ===== GUI INPUTS =====
    kOscMix chnget "oscMix"
    kDetune chnget "detune"
    kCut chnget "cutoff"
    kRes chnget "resonance"
    kFiltAmt chnget "filtEnvAmt"

    kAmpAtt chnget "ampAtt"
    kAmpDec chnget "ampDec"
    kAmpSus chnget "ampSus"
    kAmpRel chnget "ampRel"

    kFiltAtt chnget "filtAtt"
    kFiltDec chnget "filtDec"
    kFiltSus chnget "filtSus"
    kFiltRel chnget "filtRel"

    kLfoRate chnget "lfoRate"
    kLfoDepth chnget "lfoDepth"
    kLfoTarget chnget "lfoTarget"
    kDrive chnget "drive"
    kMaster chnget "masterVol"

    kFreq = p4

    ;; ===== AMP ENV =====
    kDurAmp = kAmpAtt + kAmpDec + kAmpRel + 0.001
    aPhAmp phasor (1/kDurAmp)
    aIndexAmp = aPhAmp * 127
    aEnvAmp tablei aIndexAmp, 10
    aEnvAmp = (aEnvAmp * kAmpSus)

    ;; ===== FILTER ENV =====
    kDurFilt = kFiltAtt + kFiltDec + kFiltRel + 0.001
    aPhFilt phasor (1/kDurFilt)
    aIndexFilt = aPhFilt * 127
    aEnvFilt tablei aIndexFilt, 11
    aEnvFilt = (aEnvFilt * kFiltSus)

    ;; ===== LFO =====
    aLFO lfo kLfoDepth, kLfoRate
    kLFOfilt downsamp aLFO
    if (kLfoTarget != 1) then
        kLFOfilt = 0
    endif

    ;; ===== OSC =====
    kDet = CentRatio(kDetune)

    aOsc1 vco2 0.5, kFreq
    aOsc2 vco2 0.5, kFreq * kDet
    aOsc = aOsc1*(1-kOscMix) + aOsc2*kOscMix

    ;; ===== FILTER =====
    kCutMod = kCut + (aEnvFilt * kFiltAmt * kCut) + (kLFOfilt * 3000)
    kCutMod limit kCutMod, 50, 18000

    aFilt moogladder aOsc, kCutMod, kRes

    ;; ===== DRIVE =====
    aDriveIn = aFilt * (1 + (kDrive*6))
    aDriven = tanh(aDriveIn)

    ;; ===== OUTPUT =====
    aSig = aDriven * aEnvAmp * kMaster
    outs aSig, aSig
endin

</CsInstruments>

<CsScore>
f 10 0 128 7 0 32 1 32 0.7 64 0
f 11 0 128 7 0 32 1 32 0.5 64 0
f0 3600
</CsScore>
</CsoundSynthesizer>
