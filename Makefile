CC = gcc
LIBS = -lm
PROGS = xm2sco orc2xi

all: ${PROGS}

install: 
	mv ${PROGS} /usr/bin/

clean: 
	rm -f ${PROGS} 

xm2sco:
	${CC} xm2sco.c -o xm2sco
orc2xi:
	${CC} orc2xi.c -o orc2xi ${LIBS}
