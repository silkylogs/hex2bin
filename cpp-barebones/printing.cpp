#pragma once

constexpr auto INVALID_HEX_CHAR = static_cast<char>(0xff);

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

template <usize t_strlen>
void PrintLineA(text<t_strlen> &str) {
    PrintStringA(str);
    PrintNewline();
}

template <usize t_strlen>
void PrintStringQoutedA(text<t_strlen> &str) {
    PrintStringA("\"", 1);
    PrintStringA(str);
    PrintStringA("\"", 1);
}

void PrintStringQoutedA(const char *str, const usize length) {
    PrintStringA("\"", 1);
    PrintStringA(str, length);
    PrintStringA("\"", 1);
}

template <usize t_strlen>
void PrintLineQoutedA(text<t_strlen> &str) {
    PrintStringQoutedA(str);
    PrintNewline();
}

void PrintLineQoutedA(const char *str, const usize length) {
    PrintStringQoutedA(str, length);
    PrintNewline();
}

char ConvNibbleToHex(u8 nibble) {
    if (nibble <= 0x9)
	return '0' + static_cast<char>(nibble);
    if (nibble <= 0xf)
	return 'A' + static_cast<char>(nibble - 10);
    return static_cast<char>(INVALID_HEX_CHAR);
}

bool PrintByte(u8 b) {
    u8 nibble_high = (b & static_cast<u8>(0xf0)) >> 4;
    u8 nibble_low = b & static_cast<u8>(0x0f);
    bool val_ok = true;
    
    char char_high = ConvNibbleToHex(nibble_high);    
    char char_low = ConvNibbleToHex(nibble_low);
    if (char_low == INVALID_HEX_CHAR || char_high == INVALID_HEX_CHAR)
	return false;
    
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

