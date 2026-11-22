#include <stdio.h>

#include "microdds/microdds.h"

int main(void)
{
    printf("MicroDDS version: %s\n",
           microdds_version());

    printf("MicroDDS publisher example\n");

    return 0;
}
