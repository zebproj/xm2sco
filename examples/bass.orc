instr 1	
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

outs aL, aR

endin
