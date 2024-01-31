#include <cstddef>
#include <cstdint>
#include "windows_includes.cpp"

void PrintStringA(const char *str, const std::size_t len) {
    void *handle = GetStdHandle(STD_OUTPUT_HANDLE);
    WriteConsoleA(handle, str, len, NULL, NULL);
}
int Main(void) {
    PrintStringA("Hello, world\n", sizeof ("Hello, world\n"));
    return 0;
}

void Startup(void) {
    auto result = Main();
    ExitProcess(result);
}
