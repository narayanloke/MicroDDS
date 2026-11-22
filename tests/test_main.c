
#include <stdio.h>
#include <string.h>

#include "microdds/microdds.h"

int main(void)
{
    const char *version = microdds_version();

    if (version == NULL || strcmp(version, "0.1.0") != 0) {
        fprintf(stderr, "FAIL: version test\n");
        return 1;
    }

    printf("[PASS] version test\n");

    return 0;
}
