#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291

extern int system_call();

void print_string(char* str) {
    int i = 0;
    while (str[i] != '\0') {
        system_call(SYS_WRITE, STDOUT, &str[i], 1);
        i++;
    }
}

int main (int argc , char* argv[], char* envp[]) {
  /*Complete the task here*/
   int i;
    for (i = 1; i < argc; i++) {
        print_string(argv[i]);
        print_string(" ");
    }
    print_string("\n");

  return 0;
}
