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
    retval.m_has_value = true;
    return retval;
}

tagged_value<u8> ConvertHexNibbleCharToBin(char c) {
    if (c >= '0' && c <= '9') return SomeValue<u8>(c - '0');
    else if (c >= 'A' && c <= 'F') return SomeValue<u8>(c - 'A' + 0xA);
    else if (c >= 'a' && c <= 'f') return SomeValue<u8>(c - 'a' + 0xa);
    else return NoValue<u8>();
}

bool ConvertHexByteToBin(char (*src)[2], u8 *dest) {
    auto hex_nibble_high = (*src)[0];
    auto hex_nibble_low = (*src)[1];

    auto bin_nibble_low = ConvertHexNibbleCharToBin(hex_nibble_low);
    auto bin_nibble_high = ConvertHexNibbleCharToBin(hex_nibble_high);

    if (!bin_nibble_low.HasValue()) return false;
    if (!bin_nibble_high.HasValue()) return false;

    *dest =
	(bin_nibble_high.Value() << 4) |
	bin_nibble_low.Value();

    return true;
}

bool Main(void) noexcept {
    auto src = text("0123456789abcdefABCDEF");
    
    auto src_text = text("Source text: ");
    PrintStringA(src_text);
    PrintStringA(src);
    PrintNewline();

    u8 dest_bytes[0xf];
    usize isrc = 0;
    usize idest = 0;
    while(true) {
	bool conversion_complete = ConvertHexByteToBin(
	    reinterpret_cast<char (*)[2]>(&src.chars()[isrc]),
	    reinterpret_cast<u8 *>(&dest_bytes[idest]));
	
	if (!conversion_complete) {
	    auto error_msg = text("Error detected during conversion");
	    PrintStringA(error_msg);
	    PrintNewline();
	    break;
	}

	isrc += 2;
	idest += 1;

	if (!(isrc < src.len()) ||
	    !(idest < sizeof dest_bytes)) break;
    }

    auto dest_bytes_text = text("Dest bytes: ");
    PrintStringA(dest_bytes_text);
    PrintMemHexByteArray(
	reinterpret_cast<u8 *>(dest_bytes),
	sizeof dest_bytes);
    PrintNewline();

    return true;
}

void Startup(void) noexcept {
    // TODO: when removing <cstdint>,
    // CheckWetherTypeSizesMeetExpectations();
    ExitProcess(!Main());
}
