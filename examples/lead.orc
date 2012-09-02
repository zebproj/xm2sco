instr 1	
ipch = cpspch(p4)
;iamp = .2
iamp = p5
kpw lfo .2, .1

kenv linsegr 0, 0.001, 1, 0.001, 0

a1 vco2 iamp*kenv, ipch, 2, .5 +kpw

outs a1, a1

endin
