#pragma once

bool MemCopy(u8 const* src, usize src_len, u8 *dest, usize dest_len) {
    if (dest_len < src_len) return false;
    for (usize i = 0; i < dest_len; ++i)
	dest[i] = src[i];
    return true;
}

usize DivRoundUp(usize numerator, usize denominator) {
    usize remainder = numerator % denominator;
    usize dividend = numerator / denominator;
    return dividend + remainder;
}
