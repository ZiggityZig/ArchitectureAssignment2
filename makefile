calc: calc.s
	nasm -f elf calc.s -o calc.o
	gcc -m32 -Wall -g calc.o -o calc
	rm -f calc.o

.PHONY: clean

clean:
	rm -f calc