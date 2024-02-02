#pragma once

tagged_value<u8> ConvertHexNibbleCharToBin(char c) {
    if (c >= '0' && c <= '9') return SomeValue<u8>(c - '0');
    else if (c >= 'A' && c <= 'F') return SomeValue<u8>(c - 'A' + 0xA);
    else if (c >= 'a' && c <= 'f') return SomeValue<u8>(c - 'a' + 0xa);
    else return NoValue<u8>();
}

bool ConvertHexByteToBin(char hex_nibble_high, char hex_nibble_low, u8 *dest) {
    auto bin_nibble_high = ConvertHexNibbleCharToBin(hex_nibble_high);
    if (!bin_nibble_high.HasValue()) return false;

    u8 bin_nibble_low_applied_value;
    auto bin_nibble_low = ConvertHexNibbleCharToBin(hex_nibble_low);
    if (bin_nibble_low.HasValue())
	bin_nibble_low_applied_value = bin_nibble_low.Value();
    else
	bin_nibble_low_applied_value = 0;

    *dest =
	(bin_nibble_high.Value() << 4) |
	bin_nibble_low_applied_value;

    return true;
}

bool ConvertHexArrayToBin(char *src, usize src_len, u8 *dest, usize dest_len) {
    // Each byte is represented by two ascii characters
    if (DivRoundUp(src_len, 2) > dest_len) {
	auto err_msg =
	    text("Error: Destination buffer has insufficient space");
	PrintLineA(err_msg);
	return false;
    }

    usize isrc = 0, idest = 0;
    while(true) {
	bool conversion_successful = ConvertHexByteToBin(
	    src[isrc], src[isrc + 1],
	    &dest[idest]);

	// Zero final unprovided nibble
	if (1 == (src_len - isrc)) dest[idest] &= 0xf0;

	if (!conversion_successful) {
	    auto error_msg = text(
		"Error: "
		"conversion from hexadecimal character to "
		"binary representation failed");
	    PrintLineA(error_msg);
	    return false;
	}

	isrc += 2;
	idest += 1;

	// This check is probably redundant
	if (!(idest <= dest_len)) {
	    auto err_msg =
		text("Error: Destination index overflow detected");
	    PrintLineA(err_msg);
	    return false;
	}

	if (!(isrc < src_len)) break;
    }

    return true;
}

bool StripWhitespace(
    char *src, usize src_len,
    char *dest, usize dest_len,
    usize *stripped_len)
{
    if (dest_len < src_len) return false;

    usize isrc = 0, idest = 0;
    while (true) {
	auto is_space { src[isrc] == ' ' };
	auto is_tab { src[isrc] == '\t' };
	auto is_whitespace { is_space || is_tab };

	if (idest > dest_len) {
	    auto err_msg =
		text("Error: Destination index overflow detected");
	    PrintLineA(err_msg);
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

    *stripped_len = idest;
    return true;
}
