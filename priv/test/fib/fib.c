
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

long
fib(long x)
{
    if (x == 0)
        return 0;

    if (x == 1)
        return 1;

    return fib(x - 1) + fib(x - 2);
}

int
main(int argc, char* argv[])
{
    assert(argc == 2);

    long x = atol(argv[1]);
    long y = fib(x);

    printf("fib(%ld) = %ld\n", x, y);

    return 0;
}
