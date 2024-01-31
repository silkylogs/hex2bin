#include <cstddef>
#include <cstdint>
//#include <Windows.h>

constexpr auto STD_INPUT_HANDLE = static_cast<std::uint32_t>(-10);
constexpr auto STD_OUTPUT_HANDLE = static_cast<std::uint32_t>(-11);
constexpr auto STD_ERROR_HANDLE = static_cast<std::uint32_t>(-12);

extern "C" void *GetStdHandle(std::uint32_t);
extern "C" void WriteConsoleA(void *, const char *, int, void *, void *);

void PrintStringA(const char *str, const std::size_t len) {
    void *handle = GetStdHandle(STD_OUTPUT_HANDLE);
    WriteConsoleA(handle, str, len, NULL, NULL);
}

int main(void) {
    PrintStringA("Hello, world\n", sizeof ("Hello, world\n"));
    return 0;
}
