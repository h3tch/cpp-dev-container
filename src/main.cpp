#include "pch.h"
#include "private-pch.h"

int main() {
  int a = 1, b = 2;
  std::cout << "add(a, b): " << add(a, b) << '\n';
  std::cout << "private_add(a, b): " << private_add(a, b) << '\n';
  std::cout << "mul(a, b): " << mul(a, b) << '\n';
  return 0;
}