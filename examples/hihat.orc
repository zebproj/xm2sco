instr 1
ipch = p4
iamp = p5
kenv linsegr iamp, .15, 0, .002, 0
a1 rand kenv 
afilt buthp a1, 12000
aL = afilt
aR = afilt
outs aL, aR
endin
