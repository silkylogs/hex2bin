#include <cstddef>
#include <cstdint>

using usize = std::size_t;
using i32 = std::int32_t;
using u8 = std::uint8_t;

constexpr auto INVALID_HEX_CHAR = static_cast<char>(0xff);

#include "windows_includes.cpp"
#include "text.cpp"
#include "printing.cpp"
#include "tagged_value.cpp"

bool MemCopy(u8 const* src, usize src_len, u8 *dest, usize dest_len) {
    if (dest_len < src_len) return false;
    for (usize i = 0; i < dest_len; ++i)
	dest[i] = src[i];
    return true;
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
    // as opposed to dividing the source length by two
    // is to account for integer division rounding down to the nearest
    // number instead of rounding up, the former of which leads to the
    // desired behaviour for this case
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


bool StripWhitespace(char *src, usize src_len, char *dest, usize dest_len) {
    if (dest_len < src_len) return false;

    usize isrc = 0, idest = 0;
    while (true) {
	auto is_space { src[isrc] == ' ' };
	auto is_tab { src[isrc] == '\t' };
	auto is_whitespace { is_space || is_tab };

	if (idest > dest_len) {
	    auto err_msg =
		text("Error: Destination index overflow detected");
	    PrintStringA(err_msg);
	    PrintNewline();
	    return false;
	}

	if (is_whitespace) {
	    isrc++;
	} else {
	    dest[idest] = src[isrc];
	    idest++;
	    isrc++;
	}

	if (isrc >= src_len) break;
    }

    return true;
}

bool Main(void) noexcept {
    u8 working_space[0xf] = "\t ba be\tb0 0b\t";
    constexpr usize working_space_len = sizeof working_space - 1;

    auto src_text = text("Source text: ");
    PrintStringA(src_text);
    PrintStringA("\"", 1);
    PrintStringA(
	reinterpret_cast<char*>(working_space),
	working_space_len);
    PrintStringA("\"", 1);
    PrintNewline();

    if(!StripWhitespace(
	   reinterpret_cast<char*>(working_space), working_space_len,
	   reinterpret_cast<char*>(working_space), working_space_len))
    {
	auto err_msg = text("Error: failed to strip whitespace");
	PrintStringA(err_msg);
	PrintNewline();
	return false;
    }

    auto stripped_text = text("After stripping whitespace: ");
    PrintStringA(stripped_text);
    PrintStringA("\"", 1);
    PrintStringA(
	reinterpret_cast<char*>(working_space),
	working_space_len);
    PrintStringA("\"", 1);
    PrintNewline();

    if(!ConvertHexArrayToBin(
	   reinterpret_cast<char*>(working_space), working_space_len,
	   working_space, working_space_len))
    {
	auto err_msg = text("Error: failed to convert hex array to binary");
	PrintStringA(err_msg);
	PrintNewline();
	//return false;
    }

    auto dest_bytes_text = text("Dest bytes: ");
    PrintStringA(dest_bytes_text);
    PrintMemHexByteArray(working_space, working_space_len);
    PrintNewline();

    return true;
}

void Startup(void) noexcept {
    // TODO: when removing <cstdint>,
    // CheckWetherTypeSizesMeetExpectations();
    ExitProcess(!Main());
}
