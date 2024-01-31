#include <cstddef>
#include <cstdint>

using usize = std::size_t;
using i32 = std::int32_t;
using u8 = std::uint8_t;

constexpr auto INVALID_HEX_CHAR = static_cast<char>(0xff);

#include "windows_includes.cpp"
#include "text.cpp"
#include "printing.cpp"

// TODO: implement a better optional struct
template <typename T>
union option {
    T m_contained_val;
    bool m_has_value;
};

template <typename T>
option<T> option_none(void) { return option<T>{0, false}; }

option<u8> ConvertHexNibbleToBin(char *src, char *dest) {
    auto c = *src;
    if (c > 'f' || c < '0') return option_none<u8>();
    return option_none<u8>();

}

/*
void ConvertHexByteToBin(char *src, char *dest) {
    auto hex_nibble_high = src[0];
    auto hex_nibble_low = src[1];
}
*/

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
    ExitProcess(Main());
}
