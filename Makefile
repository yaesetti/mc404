prog.x: file.o
	ld.lld file.o -o prog.x

file.o: file.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file.s -c -o file.o

file.s: file.c
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file.c -c -o file.s

clean:
	rm -f *.o prog.x
