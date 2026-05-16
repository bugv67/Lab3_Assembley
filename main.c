#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291

extern int system_call();

int main(int argc, char *argv[], char *envp[])
{
    // start.s will run before?
    // print arg without printf, use system call
    /*Complete the task here*/

    for (int i = 0; i < argc; i++)
    {
        char *arg = argv[i];
        unsigned int len = strlen(arg);
        system_call(SYS_WRITE, STDOUT, arg, len); // 4 ,1
        system_call(SYS_WRITE, STDOUT, "\n", 1);
    }

    return 0;
}