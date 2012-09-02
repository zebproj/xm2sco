gisine ftgenonce 1, 0, 4096, 10, 1
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
outs aOut, aOut
endin
