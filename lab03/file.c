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

#define STDIN_FD  0
#define STDOUT_FD 1

#define INT_MIN -2147483648

int hex2int(char *hex, int n) {
    int val = 0;

    for (int i = 2; i < n; i++) {
        if (hex[i] <= '9') {
            val = val * 16 + hex[i] - '0';
        }
        else {
            val = val * 16 + hex[i] - 'a' + 10;
        }
    }

    return val;
}

int dec2int(char *dec, int n) {
    int val = 0;

    if (dec[0] == '-') {
        for (int i = 1; i < n; i++) {
            val = val * 10 - (dec[i] - '0');
        }
    }
    else {
        for (int i = 0; i < n; i++) {
            val = val * 10 + (dec[i] - '0');
        }
    }

    return val;
}

void print_bin(int num) {
    int started = 0;
    char buff[36];
    int pos = 0;

    buff[pos++] = '0';
    buff[pos++] = 'b';

    if (num == 0) {
        buff[pos++] = '0';
        buff[pos++] = '\n';
        buff[pos] = '\0';
        write(STDOUT_FD, buff, pos);
        return;
    }

    for (int i = 31; i >= 0; i--) {
        if ((num >> i) & 1) {
            buff[pos++] = '1';
            started = 1;
        }
        else if (started) {
            buff[pos++] = '0';
        }
    }
    buff[pos++] = '\n';
    buff[pos] = '\0';

    write(STDOUT_FD, buff, pos);
}

void print_dec(int num) {
    char buff[35];
    int pos = 0;

    if (num == 0) {
        buff[pos++] = '0';
        buff[pos++] = '\n';
        buff[pos] = '\0';
        write(STDOUT_FD, buff, pos);
        return;
    }

    if (num == INT_MIN) {
        char buff_int_min[] = "-2147483648\n\0";
        write(STDOUT_FD, buff_int_min, 12);
        return;
    }

    if (num < 0) {
        num = -num;
        buff[pos++] = '-';
    }

    char temp[32];
    int pos_temp = 0;

    while (num > 0) {
        temp[pos_temp++] = (num % 10) + '0';
        num = num / 10;
    }

    while (pos_temp > 0) {
        buff[pos++] = temp[--pos_temp];
    }

    buff[pos++] = '\n';
    buff[pos] = '\0';

    write(STDOUT_FD, buff, pos);
}

void print_hex(int num) {
    char buff[11];
    int pos = 0;
    int started = 0;

    buff[pos++] = '0';
    buff[pos++] = 'x';

    if (num == 0) {
        buff[pos++] = '0';
        buff[pos++] = '\n';
        buff[pos] = '\0';
        write(STDOUT_FD, buff, pos);
        return;
    }

    if (num == INT_MIN) {
        char buff_int_min[] = "0x80000000\n\0";
        write(STDOUT_FD, buff_int_min, 11);
        return;
    }

    for (int i = 28; i >= 0; i = i - 4) {
        int four_bits = (num >> i) & 0xf;

        if (four_bits != 0 || started) {
            started = 1;
            if (four_bits < 10) {
                buff[pos++] = four_bits + '0';
            }
            else {
                buff[pos++] = four_bits + 'a' - 10;
            }
        }
    }

    buff[pos++] = '\n';
    buff[pos] = '\0';

    write(STDOUT_FD, buff, pos);
}

void print_swap(int num) {
    unsigned int unsigned_num = (unsigned int) num;
    unsigned int int_swapped;

    int_swapped = (unsigned_num >> 24) & 0x000000ff |
                  (unsigned_num >> 8 ) & 0x0000ff00 |
                  (unsigned_num << 8 ) & 0x00ff0000 |
                  (unsigned_num << 24) & 0xff000000;

    char buff[35];
    int pos = 0;

    char temp[32];
    int pos_temp = 0;

    while (int_swapped > 0) {
        temp[pos_temp++] = (int_swapped % 10) + '0';
        int_swapped = int_swapped / 10;
    }

    while (pos_temp > 0) {
        buff[pos++] = temp[--pos_temp];
    }

    buff[pos++] = '\n';
    buff[pos] = '\0';

    write(STDOUT_FD, buff, pos);
}

int main()
{
    char str[20];
    int n = read(STDIN_FD, str, 20) - 1;
    int int_num;

    if (str[1] == 'x') {
        int_num = hex2int(str, n);
    }
    else {
        int_num = dec2int(str, n);
    }

    print_bin(int_num);
    print_dec(int_num);
    print_hex(int_num);
    print_swap(int_num);

    return 0;
}
