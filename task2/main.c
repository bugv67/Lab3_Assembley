#include "util.h"

#define SYS_EXIT 1
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_GETDENTS 141

#define O_RDONLY 0

/* Linux kernel dirent structure for 32-bit systems */
struct linux_dirent
{
    unsigned long d_ino;     /* Inode number */
    unsigned long d_off;     /* Offset to next linux_dirent */
    unsigned short d_reclen; /* Length of this linux_dirent */
    char d_name[];           /* Filename (null-terminated) */
};

int main(int argc, char *argv[])
{
    int i;
    char prefix = 0;
    int has_prefix = 0;
    int fd;
    int nread;
    int bpos = 0;
    char buf[8192];
}