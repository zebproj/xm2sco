<CsoundSynthesizer>
<CsOptions>
-d
-odac:system:playback_
;-M hw:0,0
-+rtaudio=jack
;-+rtaudio=alsa
;-+rtmidi=alsa
;--midi-key-pch=4
;--midi-velocity-amp=5
</CsOptions>
; ==============================================
<CsInstruments>

;sr	=	96000
sr	=	44100
ksmps	=	1
nchnls	=	2
0dbfs	=	1


gakick init 0
gasnare init 0
gahihat init 0
gafmarp init 0
gabass init 0
galead init 0

gisine ftgenonce 1, 0, 4096, 10, 1
alwayson 999

instr 999
ikick = .6
isnare = .4
ihihat = .3
ibass = .3
iarp = .4
ilead = .2

aL sum gakick*ikick, gasnare*isnare, gahihat*ihihat, gafmarp*iarp, gabass*ibass, galead*ilead

;aL limit aL, -1, 1

aR = aL
outs aL, aR
gakick = 0
gasnare = 0
gahihat = 0
gafmarp = 0 
gabass = 0
galead = 0
endin


instr  1	
ipch = p4
;iamp = 1
iamp = p5 * 1.5 ;extra boost

klik expseg 0.00001, 0.0001, 1, 0.01, 1, 0.120, 0.01, 0.4, 0.00001

aclick randh 3*klik, 5000*klik
aclick clip aclick, 0, 1
;aclick butlp aclick, 6000*klik
;aclick rand (iamp*.5)*klik
idecay random 1.2, 2.3
kenv expsegr 1, idecay, 0.0000001, 0.01, 0.0000001
kdrop expseg 120, .8, 10 

a1 oscil iamp*kenv, kdrop, gisine
asub oscil iamp*kenv, 60, gisine

a1 butlp a1, 300

aOut = a1*.5 + asub*.5 + aclick*.1
;aOut = aclick
;outs aOut, aOut
gakick = gakick + aOut
endin


instr 2
ipch = p4
iamp = p5 
ih = 0.05
ir = 0.05

kenv linsegr 0, 0.001, iamp, 0.05, iamp, 0.01, iamp*.5,  0.2, 0, 0.001, 0

/*
a1 rand kenv 
a2 rand kenv 
*/

a1 randh kenv, 4000
a2 randh kenv, 4000


afilt1	moogvcf a1, 5000 + 5000 * iamp * kenv, 0.6
afilt2	moogvcf a2, 5000 + 5000 * iamp * kenv, 0.6

aL	= afilt1
aR	= afilt2
;outs aL, aR
gasnare = gasnare + aL
endin


instr 3
ipch = p4
iamp = p5
kenv linsegr iamp, .15, 0, .002, 0
a1 rand kenv 
afilt buthp a1, 12000
aL = afilt
aR = afilt
;outs aL, aR
gahihat = gahihat + aL
endin


instr 4	
ipch = cpspch(p4)
iamp = .2
imod = p5
;iamp = p5
kenv linsegr 0, 0.001, 1, 0.005, 0
a1 foscil iamp*kenv, ipch, 3, 5, 5*imod, gisine
;outs a1, a1
gafmarp = gafmarp + a1
endin

instr 5	
ipch = cpspch(p4)
iamp = p5

kenv linsegr 0, 0.001, 1, .7, 0, 0.1, 0

a1 vco2 iamp*kenv, ipch*.25, 0
a2 vco2 iamp*kenv, ipch*.25*1.002, 0
a3 vco2 iamp*kenv, ipch*.25*.998, 0

a1 sum a1, a2, a3
a1 = a1 * .333

afilt moogvcf a1, 4000*kenv, 0

aL = afilt

aR = afilt

;outs aL, aR
gabass = gabass + aL
endin

instr 6	
ipch = cpspch(p4)
;iamp = .2
iamp = p5
kpw lfo .2, .1

kenv linsegr 0, 0.001, 1, 0.001, 0

a1 vco2 iamp*kenv, ipch, 2, .5 +kpw

;outs a1, a1
galead = galead + a1

endin
</CsInstruments>
; ==============================================
<CsScore>
;f 0 999

t 0 135
;Pattern 0
i 4 0 0.125 8.04 1
i 4 0.25 0.125 8.04 0.5
i 3 0 0.5 8.00 1
i 5 0 0.5 7.04 1
i 4 0.5 0.125 8.04 0.75
i 4 0.75 0.125 8.07 0.5
i 1 0 1 8.00 1
i 3 0.5 0.5 8.00 1
i 5 0.5 0.5 7.04 1
i 4 1 0.125 8.04 1
i 4 1.25 0.125 8.04 0.5
i 3 1 0.5 8.00 1
i 5 1 0.5 8.04 1
i 4 1.5 0.125 8.04 0.75
i 5 1.5 0.25 7.04 1
i 4 1.75 0.125 8.04 0.5
i 1 1 1 8.00 1
i 3 1.5 0.5 8.00 1
i 4 2 0.125 8.07 1
i 4 2.25 0.125 8.04 0.5
i 3 2 0.5 8.00 1
i 5 1.75 0.75 7.00 1
i 4 2.5 0.125 8.04 0.75
i 5 2.5 0.25 8.00 1
i 4 2.75 0.125 8.04 0.5
i 1 2 1 8.00 1
i 2 1 2 8.00 1
i 3 2.5 0.5 8.00 1
i 5 2.75 0.25 7.00 1
i 4 3 0.125 8.04 1
i 4 3.25 0.125 8.07 0.5
i 1 3 0.5 8.00 1
i 3 3 0.5 8.00 1
i 5 3 0.5 8.02 1
i 4 3.5 0.125 8.04 0.75
i 2 3 0.75 8.00 1
i 4 3.75 0.125 8.09 0.5
i 1 3.5 0.5 8.00 1
i 3 3.5 0.5 8.00 1
i 5 3.5 0.5 7.02 1
i 4 4 0.125 8.04 1
i 4 4.25 0.125 8.04 0.5
i 3 4 0.5 8.00 1
i 4 4.5 0.125 8.04 0.75
i 5 4 0.75 7.04 1
i 4 4.75 0.125 8.07 0.5
i 1 4 1 8.00 1
i 2 3.75 1.25 8.00 1
i 3 4.5 0.5 8.00 1
i 4 5 0.125 8.04 1
i 4 5.25 0.125 8.04 0.5
i 3 5 0.5 8.00 1
i 5 4.75 0.75 7.11 1
i 4 5.5 0.125 8.04 0.75
i 5 5.5 0.25 8.04 1
i 4 5.75 0.125 8.04 0.5
i 1 5 1 8.00 1
i 3 5.5 0.5 8.00 1
i 4 6 0.125 8.07 1
i 4 6.25 0.125 8.04 0.5
i 3 6 0.5 8.00 1
i 5 5.75 0.75 7.00 1
i 4 6.5 0.125 8.04 0.75
i 5 6.5 0.25 8.00 1
i 4 6.75 0.125 8.04 0.5
i 1 6 1 8.00 1
i 2 5 2 8.00 1
i 3 6.5 0.5 8.00 1
i 5 6.75 0.25 7.00 1
i 4 7 0.125 8.04 1
i 4 7.25 0.125 8.07 0.5
i 1 7 0.5 8.00 1
i 3 7 0.5 8.00 1
i 5 7 0.5 8.02 1
i 4 7.5 0.125 8.04 0.75
i 2 7 0.75 8.00 1
i 4 7.75 0.125 8.09 0.5
;Pattern 2
i 1 7.5 0.5 8.00 1
i 3 7.5 0.5 8.00 1
i 5 7.5 0.5 7.02 1
i 4 8 0.125 8.04 1
i 4 8.25 0.125 8.04 0.5
i 3 8 0.5 8.00 1
i 5 8 0.5 7.04 1
i 4 8.5 0.125 8.04 0.75
i 6 8 0.75 8.11 1
i 4 8.75 0.125 8.07 0.5
i 1 8 1 8.00 1
i 2 7.75 1.25 8.00 1
i 3 8.5 0.5 8.00 1
i 5 8.5 0.5 7.04 1
i 4 9 0.125 8.04 1
i 4 9.25 0.125 8.04 0.5
i 3 9 0.5 8.00 1
i 5 9 0.5 8.04 1
i 6 8.75 0.75 8.07 1
i 4 9.5 0.125 8.04 0.75
i 5 9.5 0.25 7.04 1
i 4 9.75 0.125 8.04 0.5
i 1 9 1 8.00 1
i 3 9.5 0.5 8.00 1
i 4 10 0.125 8.07 1
i 4 10.25 0.125 8.04 0.5
i 3 10 0.5 8.00 1
i 5 9.75 0.75 7.00 1
i 6 9.5 1 9.00 1
i 4 10.5 0.125 8.04 0.75
i 5 10.5 0.25 8.00 1
i 4 10.75 0.125 8.04 0.5
i 1 10 1 8.00 1
i 2 9 2 8.00 1
i 3 10.5 0.5 8.00 1
i 5 10.75 0.25 7.00 1
i 6 10.5 0.5 8.11 1
i 4 11 0.125 8.04 1
i 4 11.25 0.125 8.07 0.5
i 1 11 0.5 8.00 1
i 3 11 0.5 8.00 1
i 5 11 0.5 8.02 1
i 6 11 0.5 8.09 1
i 4 11.5 0.125 8.04 0.75
i 2 11 0.75 8.00 1
i 4 11.75 0.125 8.09 0.5
i 1 11.5 0.5 8.00 1
i 3 11.5 0.5 8.00 1
i 5 11.5 0.5 7.02 1
i 6 11.5 0.5 8.07 1
i 4 12 0.125 8.04 1
i 4 12.25 0.125 8.04 0.5
i 3 12 0.5 8.00 1
i 4 12.5 0.125 8.04 0.75
i 5 12 0.75 7.04 1
i 6 12 0.75 8.04 1
i 4 12.75 0.125 8.07 0.5
i 1 12 1 8.00 1
i 2 11.75 1.25 8.00 1
i 3 12.5 0.5 8.00 1
i 4 13 0.125 8.04 1
i 4 13.25 0.125 8.04 0.5
i 3 13 0.5 8.00 1
i 5 12.75 0.75 7.11 1
i 6 12.75 0.75 8.07 1
i 4 13.5 0.125 8.04 0.75
i 5 13.5 0.25 8.04 1
i 4 13.75 0.125 8.04 0.5
i 1 13 1 8.00 1
i 3 13.5 0.5 8.00 1
i 4 14 0.125 8.07 1
i 4 14.25 0.125 8.04 0.5
i 3 14 0.5 8.00 1
i 5 13.75 0.75 7.00 1
i 4 14.5 0.125 8.04 0.75
i 5 14.5 0.25 8.00 1
i 4 14.75 0.125 8.04 0.5
i 1 14 1 8.00 1
i 2 13 2 8.00 1
i 3 14.5 0.5 8.00 1
i 5 14.75 0.25 7.00 1
i 6 13.5 1.5 8.02 1
i 4 15 0.125 8.04 1
i 4 15.25 0.125 8.07 0.5
i 1 15 0.5 8.00 1
i 3 15 0.5 8.00 1
i 5 15 0.5 8.02 1
i 4 15.5 0.125 8.04 0.75
i 2 15 0.75 8.00 1
i 4 15.75 0.125 8.09 0.5
;Pattern 3
i 1 15.5 0.5 8.00 1
i 3 15.5 0.5 8.00 1
i 5 15.5 0.5 7.02 1
i 4 16 0.125 8.04 1
i 4 16.25 0.125 8.04 0.5
i 3 16 0.5 8.00 1
i 5 16 0.5 7.04 1
i 4 16.5 0.125 8.04 0.75
i 6 16 0.75 8.11 1
i 4 16.75 0.125 8.07 0.5
i 1 16 1 8.00 1
i 2 15.75 1.25 8.00 1
i 3 16.5 0.5 8.00 1
i 5 16.5 0.5 7.04 1
i 4 17 0.125 8.04 1
i 4 17.25 0.125 8.04 0.5
i 3 17 0.5 8.00 1
i 5 17 0.5 8.04 1
i 6 16.75 0.75 8.07 1
i 4 17.5 0.125 8.04 0.75
i 5 17.5 0.25 7.04 1
i 4 17.75 0.125 8.04 0.5
i 1 17 1 8.00 1
i 3 17.5 0.5 8.00 1
i 4 18 0.125 8.07 1
i 4 18.25 0.125 8.04 0.5
i 3 18 0.5 8.00 1
i 5 17.75 0.75 7.00 1
i 6 17.5 1 9.04 1
i 4 18.5 0.125 8.04 0.75
i 5 18.5 0.25 8.00 1
i 4 18.75 0.125 8.04 0.5
i 1 18 1 8.00 1
i 2 17 2 8.00 1
i 3 18.5 0.5 8.00 1
i 5 18.75 0.25 7.00 1
i 6 18.5 0.5 9.02 1
i 4 19 0.125 8.04 1
i 4 19.25 0.125 8.07 0.5
i 1 19 0.5 8.00 1
i 3 19 0.5 8.00 1
i 5 19 0.5 8.02 1
i 6 19 0.5 9.00 1
i 4 19.5 0.125 8.04 0.75
i 2 19 0.75 8.00 1
i 4 19.75 0.125 8.09 0.5
i 1 19.5 0.5 8.00 1
i 3 19.5 0.5 8.00 1
i 5 19.5 0.5 7.02 1
i 6 19.5 0.5 8.11 1
i 4 20 0.125 8.04 1
i 4 20.25 0.125 8.04 0.5
i 3 20 0.5 8.00 1
i 4 20.5 0.125 8.04 0.75
i 5 20 0.75 7.04 1
i 6 20 0.75 8.09 1
i 4 20.75 0.125 8.07 0.5
i 1 20 1 8.00 1
i 2 19.75 1.25 8.00 1
i 3 20.5 0.5 8.00 1
i 4 21 0.125 8.04 1
i 4 21.25 0.125 8.04 0.5
i 3 21 0.5 8.00 1
i 5 20.75 0.75 7.11 1
i 6 20.75 0.75 9.00 1
i 4 21.5 0.125 8.04 0.75
i 5 21.5 0.25 8.04 1
i 4 21.75 0.125 8.04 0.5
i 1 21 1 8.00 1
i 3 21.5 0.5 8.00 1
i 4 22 0.125 8.07 1
i 4 22.25 0.125 8.04 0.5
i 3 22 0.5 8.00 1
i 5 21.75 0.75 7.00 1
i 4 22.5 0.125 8.04 0.75
i 5 22.5 0.25 8.00 1
i 4 22.75 0.125 8.04 0.5
i 1 22 1 8.00 1
i 2 21 2 8.00 1
i 3 22.5 0.5 8.00 1
i 5 22.75 0.25 7.00 1
i 6 21.5 1.5 8.07 1
i 4 23 0.125 8.04 1
i 4 23.25 0.125 8.07 0.5
i 1 23 0.5 8.00 1
i 3 23 0.5 8.00 1
i 5 23 0.5 8.02 1
i 4 23.5 0.125 8.04 0.75
i 2 23 0.75 8.00 1
i 4 23.75 0.125 8.09 0.5
;Pattern 4
i 1 23.5 0.5 8.00 1
i 6 24 0.25 9.04 1
i 2 23.75 0.75 8.00 1
i 6 24.5 0.25 9.04 0.25
i 6 24.75 0.25 9.02 1
i 3 23.5 1.5 8.00 1
i 6 25 0.25 9.04 0.078125
i 6 25.25 0.25 9.02 0.25
i 6 25.5 0.25 9.04 1
i 6 25.75 0.25 9.02 0.078125
i 6 26 0.25 9.04 0.25
i 6 26.5 0.25 9.04 0.078125
i 5 23.5 8.5 7.02 1
</CsScore>
</CsoundSynthesizer>

