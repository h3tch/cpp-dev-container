#include "pch.h"

extern "C" int add(int a, int b)
{
    return a + b;
}

int private_add(int a, int b)
{
    return a + b;
}