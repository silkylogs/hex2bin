#include <cstddef>
#include <cstdint>

using usize = std::size_t;
using i32 = std::int32_t;
using u32 = std::uint32_t;
using u16 = std::uint16_t;
using u8 = std::uint8_t;


#include "windows_includes.cpp"
#include "text.cpp"
#include "printing.cpp"
#include "tagged_value.cpp"
#include "misc_utility.cpp"
#include "hex_to_bin_converters.cpp"

struct string_slice {
    char *chars;
    usize len;

    char operator[](usize index) {
	return chars[index];
    }
    
    bool operator==(const string_slice &other) {
	return (other.chars == this->chars) && (other.len == this->len);
    }
};

struct cmd_line_details {
    string_slice input_filename;
    string_slice output_filename;
};

cmd_line_details ParseCommandLineA(char const* cmdline) {
    string_slice unsliced_cmdline {
	.chars = const_cast<char*>(cmdline),
	.len = 0,
    };
    {
	char *ptr = unsliced_cmdline.chars;
	while(*ptr != 0) {
	    unsliced_cmdline.len++;
	    ptr++;
	}
    }

    string_slice filename_in;
    string_slice filename_out;

    string_slice current_word = unsliced_cmdline;
    current_word.len = 0;
    for (usize i = 0; i < unsliced_cmdline.len; ++i) {
	;
    }
    
    PrintLineQoutedA(filename_in.chars, filename_in.len);
    PrintLineQoutedA(filename_out.chars, filename_out.len);
    return cmd_line_details {
	.input_filename = filename_in,
	.output_filename = filename_out,
    };
}

u8 working_space[] = "\t ba be\tb0 0b\tabcd eff";
constexpr usize working_space_len = sizeof working_space - 1;

bool Main(char *command_line) {
    const char *test_cmdline =
	"c:/convoluted\\path\\..\\hex2bin.exe "
	"valid_input.txt invalid_input.txt "
	"-o valid_output.bin invalid_out.bin";
    
    auto parsed_command_line = ParseCommandLineA(test_cmdline);
    
    auto src_text = text("Source text: ");
    PrintStringA(src_text);
    PrintLineQoutedA(
	reinterpret_cast<char*>(working_space),
	working_space_len);

    
    usize stripped_len;
    if(!StripWhitespace(
	   reinterpret_cast<char*>(working_space), working_space_len,
	   reinterpret_cast<char*>(working_space), working_space_len,
	   &stripped_len))
    {
	auto err_msg = text("Error: failed to strip whitespace");
	PrintLineA(err_msg);
	return false;
    }
    auto stripped_text = text("After stripping whitespace: ");
    PrintStringA(stripped_text);
    PrintLineQoutedA(
	reinterpret_cast<char*>(working_space),
	stripped_len);

    
    auto bin_len = DivRoundUp(stripped_len, 2);
    if(!ConvertHexArrayToBin(
	   reinterpret_cast<char*>(working_space), stripped_len,
	   working_space, bin_len))
    {
	auto err_msg = text("Error: failed to convert hex array to binary");
	PrintLineA(err_msg);
	return false;
    }
    auto dest_bytes_text = text("Dest bytes: ");
    PrintStringA(dest_bytes_text);
    PrintMemHexByteArray(working_space, bin_len);
    PrintNewline();

    
    return true;
}

void Startup(void) noexcept {
    // TODO: when removing <cstdint>,
    // CheckWetherTypeSizesMeetExpectations();
    char *command_line = GetCommandLineA();
    bool result = Main(command_line);
    ExitProcess(!result);
}
