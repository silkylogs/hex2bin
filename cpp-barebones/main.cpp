#include <cstddef>
#include <cstdint>

using usize = std::size_t;
using i32 = std::int32_t;
using u8 = std::uint8_t;

constexpr auto INVALID_HEX_CHAR = static_cast<char>(0xff);

#include "windows_includes.cpp"
#include "text.cpp"
#include "printing.cpp"

template <typename T>
struct tagged_value {
    union { T m_contained_val; };
    bool m_has_value;

    bool HasValue(void) {
	return m_has_value;
    }

    T Value(void) {
	return m_contained_val;
    }
};

struct nothing {};

template <typename T>
tagged_value<T> NoValue(void) {
    tagged_value<T> retval;
    retval.m_has_value = false;
    return retval;
}

template <typename T>
tagged_value<T> SomeValue(T val) {
    tagged_value<T> retval;
    retval.m_contained_val = val;
    retval.m_has_value = false;
    return retval;
}

tagged_value<u8> ConvertHexNibbleCharToBin(char c) {
    if (c >= '0' || c <= '9') return SomeValue<u8>(c - '0');
    if (c >= 'F' || c <= 'F') return SomeValue<u8>(c - 'A');
    if (c >= 'a' || c <= 'f') return SomeValue<u8>(c - 'a');
    return NoValue<u8>();
}

bool ConvertHexByteToBin(char (*src)[2], u8 *dest) {
    auto hex_nibble_high = *src[0];
    auto hex_nibble_low = *src[1];

    auto bin_nibble_low = ConvertHexNibbleCharToBin(hex_nibble_low);
    auto bin_nibble_high = ConvertHexNibbleCharToBin(hex_nibble_high);

    if (!bin_nibble_low.HasValue()) return false;
    if (!bin_nibble_high.HasValue()) return false;

    *dest = (char)55;/*
	(bin_nibble_high.Value() << 4) |
	bin_nibble_low.Value();*/

    return true;
}

void WriteStuffToDest(char (*src)[2], u8 *dest) {
    *dest = *src[0] + *src[1];
}

int Main(void) noexcept {
    char src[] = "11";
    auto src_text = text("Source text: ");
    PrintStringA(src_text);
    PrintStringA(src, sizeof src);
    PrintNewline();

    char dest_byte;
    bool conversion_complete = ConvertHexByteToBin(
	reinterpret_cast<char (*)[2]>(src),
	reinterpret_cast<u8 *>(&dest_byte));
    if (!conversion_complete) {
	auto error_msg = text("Error detected during conversion");
	PrintStringA(error_msg);
	return 1;
    }

    auto dest_bytes_text = text("Dest bytes: ");
    PrintStringA(dest_bytes_text);
    PrintMemHexByteArray(reinterpret_cast<u8 *>(&dest_byte), 1);
    PrintNewline();

    return 0;
}

void Startup(void) noexcept {
    ExitProcess(Main());
}
