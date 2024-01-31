#include <cstddef>
#include <cstdint>
#include <optional>

using usize = std::size_t;
using i32 = std::int32_t;
using u8 = std::uint8_t;
using byte = std::byte;

#include "windows_includes.cpp"
#include "text.cpp"

void PrintStringA(const char *str, const usize length) noexcept {
    if (length <= 0) return;
    void *handle = GetStdHandle(STD_OUTPUT_HANDLE);

    // TODO: print in chunks of i32::MAX
    auto len = static_cast<i32>(length);
    WriteConsoleA(handle, str, len, NULL, NULL);
}

template <usize t_strlen>
void PrintStringA(text<t_strlen> &str) {
    PrintStringA(str.chars(), str.len());
}

void PrintNewline(void) {
    auto newline = text("\n");
    PrintStringA(newline);
}

// Returns 0xff if not a hex char
std::optional<char> ConvNibbleToHex(u8 nibble) {
    if (nibble <= 0x9)
	return std::make_optional('0' + static_cast<char>(nibble));
    if (nibble <= 0xf)
	return std::make_optional('A' + static_cast<char>(nibble - 10));
    return std::make_optional(static_cast<char>(0xff));
}

bool PrintByte(u8 b) {
    u8 nibble_high = (b & static_cast<u8>(0xf0)) >> 4;
    u8 nibble_low = b & static_cast<u8>(0x0f);
    bool val_ok = true;
    
    char char_high = ConvNibbleToHex(nibble_high).value_or('?');
    char char_low = ConvNibbleToHex(nibble_low).value_or('?');
    
    PrintStringA(&char_high, 1);
    PrintStringA(&char_low, 1);
    
    return val_ok;
}

void PrintMemHexByteArray(u8 *mem, usize len) {
    auto lbrace = text("[");
    auto rbrace = text("]");
    auto middle = text(", ");
    
    PrintStringA(lbrace);

    for (auto i = 0; i < len - 1; ++i) {
	PrintByte(mem[i]);
	PrintStringA(middle);
    }
    PrintByte(mem[len - 1]);
    
    PrintStringA(rbrace);
}


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
