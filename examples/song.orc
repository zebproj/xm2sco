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

aL limit aL, -1, 1

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
