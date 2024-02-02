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

    auto bin_nibble_high = ConvertHexNibbleCharToBin(hex_nibble_high);
    if (!bin_nibble_high.HasValue()) return false;

    u8 bin_nibble_low_applied_value = 0;
    auto bin_nibble_low = ConvertHexNibbleCharToBin(hex_nibble_low);
    if (bin_nibble_low.HasValue())
	bin_nibble_low_applied_value = bin_nibble_low.Value();

    *dest =
	(bin_nibble_high.Value() << 4) |
	bin_nibble_low_applied_value;

    return true;
}

bool ConvertHexArrayToBin(char *src, usize src_len, u8 *dest, usize dest_len) {
    // Note: The reason destination length is multiplied by two
    // is to account for integer division rounding down to the nearest
    // number instead of rounding up, which will lead to the the
    // desired behaviour in this case
    if (src_len > dest_len * 2) {
	auto err_msg =
	    text("Error: Destination buffer has insufficient space");
	PrintStringA(err_msg);
	PrintNewline();
	return false;
    }

    usize isrc = 0, idest = 0;
    while(true) {
	bool conversion_successful = ConvertHexByteToBin(
	    reinterpret_cast<char (*)[2]>(&src[isrc]),
	    &dest[idest]);
	
	if (!conversion_successful) {
	    auto error_msg = text(
		"Error: "
		"conversion from hexadecimal character to "
		"binary representation failed");
	    PrintStringA(error_msg);
	    PrintNewline();
	    return false;
	}

	isrc += 2;
	idest += 1;

	// This check is probably redundant
	if (!(idest <= dest_len)) {
	    auto err_msg =
		text("Error: Destination index overflow detected");
	    PrintStringA(err_msg);
	    PrintNewline();
	    return false;
	}
	
	if (!(isrc < src_len)) break;
    }

    return true;
}

bool Main(void) noexcept {
    auto src = text("0123456789abcdefABCDEFcafebabe");
    
    auto src_text = text("Source text: ");
    PrintStringA(src_text);
    PrintStringA(src);
    PrintNewline();

    u8 dest_bytes[0xf];
    ConvertHexArrayToBin(
	src.chars(), src.len(),
	dest_bytes, sizeof dest_bytes);

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
