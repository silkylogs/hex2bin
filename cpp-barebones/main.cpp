#include <cstddef>
#include <cstdint>

using usize = std::size_t;
using i32 = std::int32_t;
using u8 = std::uint8_t;
using byte = std::byte;

constexpr auto INVALID_HEX_CHAR = static_cast<char>(0xff);

#include "windows_includes.cpp"
#include "text.cpp"
#include "printing.cpp"

int Main(void) noexcept {
    auto str = text("0123456789");
    PrintStringA(str);
    PrintNewline();

    u8 mem[] { 1, 2, 3, 4, 5, 10, 25, 100, 200, 255 };
    PrintMemHexByteArray(mem, sizeof mem);
    PrintNewline();
    
    return 0;
}

void Startup(void) noexcept {
    auto result = Main();
    ExitProcess(result);
}
