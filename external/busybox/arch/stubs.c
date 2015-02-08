#include <unistd.h>
#include <time.h>
#include <stdint.h>
#include <sys/types.h>
#include <grp.h>
#include <sys/sysinfo.h>


long gethostid(void) {
    return -1;
}

int getlogin_r(char *buf, size_t bufsize) {
    return -1;
}

void endgrent(void) {
}


