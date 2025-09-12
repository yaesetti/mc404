prog.x: file.o
	ld.lld file.o -o prog.x

file.o: file.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file.s -c -o file.o

clean:
	rm -f *.o prog.x
