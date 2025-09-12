int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

int dec2int(char *dec, int n) {
    int val = 0;

    if (dec[0] == '-') {
        for (int i = 1; i < n; i++) {
            val = val * 10 - (dec[i] - '0');
        }
    }
    else {
        for (int i = 1; i < n; i++) {
            val = val * 10 + (dec[i] - '0');
        }
    }

    return val;
}

#define STDIN_FD  0
#define STDOUT_FD 1

int main() {
    char buff[30];
    int n = read(STDIN_FD, buff, 30) - 1;
    
    int values[5];
    for (int i = 0; i < 5; i++) {
        char temp[5];
        for (int j = 0; j < 5; j++) {
            temp[j] = buff[i * 6 + j];
        }
        values[i] = dec2int(temp, 5);
    }

    int packed = 0;

    packed = packed | (values[4] & 0b11111111111);
    packed = (packed <<  5) | (values[3] & 0b11111);
    packed = (packed <<  5) | (values[2] & 0b11111);
    packed = (packed <<  8) | (values[1] & 0b11111111);
    packed = (packed <<  3) | (values[0] & 0b111);

    hex_code(packed);

    return 0;
}
