#include "pch.h"
#include "gtest/gtest.h"

namespace {

TEST(test, add)
{
    EXPECT_EQ(add(1, 2), 3);
}

TEST(test, mul)
{
    EXPECT_EQ(mul(3, 2), 6);
}

}
