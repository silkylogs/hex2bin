#include <iostream>
#include <ranges>
#include <string>
#include <string_view>
#include <vector>
#include <optional>
#include <fstream>
#include <filesystem>

// TODO: add a readme for this project
namespace h2b {
	static const struct ErrorMessages {
		std::string_view no_infiles { "Error: no infiles detected" };
		std::string_view no_outfiles { "Error: no outfiles detected" };
		std::string_view too_many_outfiles {
			"Error: Too many outfiles present. "
			"Only one (1) maximum outfile is allowed"
		};
		std::string_view couldnt_open_one_or_more_files {
			"Error: One or more files could not be opened"
		};
		std::string_view couldnt_open_particular_input_file {
			"Error: Couldnt open a particular input file"
		};
		std::string_view ending_delimiter_found_without_starting_delimiter {
			"Error: An ending delimiter has been found "
			"without its corresponding starting delimiter"
		};
		std::string_view couldnt_open_output_file {
			"Error: Couldnt open output file"
		};
	} error_messages;
	
	std::string_view help_prompt { "Type -h to see program usage" };
	std::string usage { "Usage: hex2bin [infile] ... [infile] -o [outfile]" };
	
	std::vector<std::string_view>
	get_infiles(std::vector<std::string_view> args) {
		std::vector<std::string_view> infiles;

		size_t dash_o_idx;
	        for (dash_o_idx = 0; dash_o_idx < args.size(); ++dash_o_idx) {
			if (args[dash_o_idx] == "-o") break;
		}

		for (size_t i = 0; i < dash_o_idx; ++i) {
			infiles.emplace_back(args[i]);
		}

		return infiles;
	}

	std::vector<std::string_view>
	get_outfiles(std::vector<std::string_view> args) {
		std::vector<std::string_view> outfiles;

		size_t dash_o_idx;
	        for (dash_o_idx = 0; dash_o_idx < args.size(); ++dash_o_idx) {
			if (args[dash_o_idx] == "-o") break;
		}

		for (size_t i = dash_o_idx + 1; i < args.size(); ++i) {
			outfiles.emplace_back(args[i]);
		}

		return outfiles;
	}

	std::optional<std::string>
	load_text_files(std::vector<std::string_view> filenames) {
		std::string text_from_all_files;

		for (auto filename: filenames) {
			std::fstream file { filename, std::ios::in };

			if (!file.is_open()) {
				std::cout
					<< error_messages.couldnt_open_particular_input_file << "\n"
					<< "The file in question: \"" << filename << "\"\n";
				return std::nullopt;
			}
			
			std::stringstream temp_str;
			temp_str <<  file.rdbuf();
			text_from_all_files += temp_str.str();
			file.close();
		}
		
		return std::make_optional(text_from_all_files);
	}

	// This is going to fail SO hard when non-ascii
	std::string
	strip_single_line_comments(std::string_view src, std::string_view comment_symbol) {
		std::string stripped;
		size_t i = 0, comment_start_idx, comment_end_idx;
		bool src_idx_in_range = true;
		
	        do {
			// A potential comment is found
			if(src[i] == comment_symbol[0]) {
				bool comment_char_found = false,
					comment_idx_in_range, should_continue_checking_for_comment;
				size_t comment_idx = 0;

				// Check wether theres indeed the rest of the comment
				comment_start_idx = i;
				comment_end_idx = comment_start_idx;
				do {
					comment_end_idx++;
					comment_idx++;

					// Index bounds checking
					comment_idx_in_range = comment_idx < comment_symbol.size();
					if (!comment_idx_in_range) break;

					src_idx_in_range =
						i < src.size();
					if (!src_idx_in_range) {
						comment_char_found = false;
						break;
					}
					
					char char_at_comment_end_idx = src[comment_end_idx];
					char char_at_comment_idx = comment_symbol[comment_idx];
					
					comment_char_found =
						char_at_comment_end_idx == char_at_comment_idx;
					should_continue_checking_for_comment =
						comment_char_found && comment_idx_in_range;
				} while(should_continue_checking_for_comment);

				bool comment_symbol_found = comment_char_found;
				if (comment_symbol_found) {
					// Set index to one char past newline, or last valid string index,
					// whichever comes first
					bool is_index_within_bounds, is_char_newline, should_break_out_of_loop;
					 
					do {
						comment_end_idx++;
						
						is_index_within_bounds =
							comment_end_idx < src.size();
						should_break_out_of_loop = !is_index_within_bounds;
						if (should_break_out_of_loop) {
							is_index_within_bounds = src.size() - 1;
							break;
						}
						
						char c = src[comment_end_idx];
						is_char_newline =
							c == '\n';
						should_break_out_of_loop =
							!is_index_within_bounds || is_char_newline;
					} while (!should_break_out_of_loop);

					i = comment_end_idx;
					continue;
				} else {
					i = comment_start_idx;
				}
			}
			// A comment is not found
			stripped += src[i];

			i++;
			src_idx_in_range = i < src.size();
		} while (src_idx_in_range);

		return stripped;
	}

	std::optional<std::string> strip_multi_line_comments_nested(
		std::string_view src,
		std::string_view delimiter_start,
		std::string_view delimiter_end)
	{
		std::string stripped_src;
		bool should_continue_checking_for_comment = true;
		bool src_idx_in_range = true;
		size_t i = 0, comment_nest_level = 0;
		bool is_comment_nest_level_zero = (comment_nest_level == 0);

		auto is_token_present_at_index = [](
			std::string_view src,
			std::string_view token,
			size_t idx) -> bool {

			bool token_char_found = false;
			// A potential comment is found
			if (src[idx] == token[0]) {
				bool token_idx_in_range, should_continue_checking_for_token;
				size_t token_idx = 0;
				
				// Check wether rest of the token is present
				size_t token_start_idx = idx;
				size_t token_end_idx = token_start_idx;
				do {
					token_end_idx++;
					token_idx++;
					
					// Index bounds checking
					bool token_idx_in_range = token_idx < token.size();
					if (!token_idx_in_range) break;
					
					bool src_idx_in_range = idx < src.size();
					if (!src_idx_in_range) {
						token_char_found = false;
						break;
					}
					
					auto char_in_src_at_token_end_idx = src[token_end_idx];
					auto char_in_token_at_token_idx = token[token_idx];
					
					token_char_found =
						char_in_src_at_token_end_idx ==
						char_in_src_at_token_end_idx;
					should_continue_checking_for_token =
						token_char_found && token_idx_in_range;
				} while(should_continue_checking_for_token);
			}

			bool token_symbol_found = token_char_found;
			return token_symbol_found;
		};

		do {	
			// A potential starting delimiter is found			
			auto delim_start_token_found_at_index =
				is_token_present_at_index(src, delimiter_start, i);
			if (delim_start_token_found_at_index) {
				i += delimiter_start.size();
				comment_nest_level++;
			}

			// An ending delimiter is found
			auto delim_end_token_found_at_index = is_token_present_at_index(
				src, delimiter_end, i);
			if (delim_end_token_found_at_index) {
				is_comment_nest_level_zero = (comment_nest_level == 0);
				if(is_comment_nest_level_zero) {
					std::cout
						<< error_messages
						.ending_delimiter_found_without_starting_delimiter << "\n";
					return std::nullopt;
				}
				
				i += delimiter_end.size();
				comment_nest_level--;
			}

			is_comment_nest_level_zero = (comment_nest_level == 0);
			if (is_comment_nest_level_zero) {
				stripped_src += src[i];
			}

			i++;
			src_idx_in_range = i < src.size();
			should_continue_checking_for_comment = src_idx_in_range;
		} while (should_continue_checking_for_comment);

		if (!is_comment_nest_level_zero) {
			std::cout <<
				"Error: Comment nest level is found to be nonzero. "
				"Current level: " << comment_nest_level << "\n";
			return std::nullopt;
		}
		return std::make_optional(stripped_src);
	}
	
	std::vector<uint8_t> hex_to_bin(std::string src_hex) {
		auto hexfilter = [](char c) -> bool {
			return (c == '0')
			| (c == '1')
			| (c == '2')
			| (c == '3')
			| (c == '4')
			| (c == '5')
			| (c == '6')
			| (c == '7')
			| (c == '8')
			| (c == '9')
			| (c == 'a')
			| (c == 'b')
			| (c == 'c')
			| (c == 'd')
			| (c == 'e')
			| (c == 'f')
			| (c == 'A')
			| (c == 'B')
			| (c == 'C')
			| (c == 'D')
			| (c == 'E')
			| (c == 'F');
		};

		auto char_to_bin = [](char c) -> std::optional<uint8_t> {
			if (c >= '0' && c <= '9') {
				return std::make_optional(c - '0');
			} else if (c >= 'A' && c <= 'F') {
				return std::make_optional((c - 'A') + 0xa);
			} else if (c >= 'a' && c <= 'f') {
				return std::make_optional((c - 'a') + 0xa);
			} else { return std::nullopt; }
		};
		
		std::string filtered_str; 
		for (auto c: src_hex | std::views::filter(hexfilter)) filtered_str += c;
		if (filtered_str.length() % 2 == 0) filtered_str += '0';

		std::vector<uint8_t> retval;
		
		for (size_t i = 0; i < filtered_str.size(); i += 2) {
			uint8_t num = (
				char_to_bin(filtered_str[i]).value_or(0) << 4)
				| char_to_bin(filtered_str[i+1]).value_or(0);
			retval.emplace_back(num);
		}
		
		return retval;
	}

	bool write_data_to_file(std::string_view filename, std::vector<uint8_t> data) {
		std::fstream file { filename, std::ios::binary | std::ios::trunc | std::ios::out };

		if (!file.is_open()) {
			std::cout
				<< error_messages.couldnt_open_output_file << "\n"
				<< "The file in question: \"" << filename << "\"\n";
			return false;
		}

		for (auto byte: data)
			file.write(reinterpret_cast<char*>(&byte), sizeof byte);
		file.close();
	}
	
	bool start(std::vector<std::string_view> args) {
		auto infiles = get_infiles({
			args.begin() + 1,
			args.end()});
		if (infiles.size() == 0) {
			std::cout
				<< error_messages.no_infiles << "\n"
				<< usage << "\n";
			return false;
		}

		auto outfiles = get_outfiles(args);
		if (outfiles.size() == 0) {
			std::cout
				<< error_messages.no_outfiles << "\n"
				<< usage << "\n";
			return false;
		}
		else if (outfiles.size() > 1) {
			std::cout
				<< error_messages.too_many_outfiles << "\n"
				<< usage << "\n";
			return false;
		}

		
		auto infile_text_data = load_text_files(infiles);
		if (!infile_text_data.has_value()) {
			std::cout << error_messages.couldnt_open_one_or_more_files << "\n";
			return false;
		}
		/*
		std::cout
			<< "Entered text:\n"
			<< "---------------------------------------------------\n"
			<< infile_text_data.value_or("No text found") << "\n";
		*/
		
		auto single_line_comment_stripped_text =
			strip_single_line_comments(infile_text_data.value(), "//");
		/*
		std::cout
			<< "Single line comment stripped text:\n"
			<< "---------------------------------------------------\n"
			<< single_line_comment_stripped_text << "\n";
		*/
		
		auto multi_line_comment_stripped_text =
			strip_multi_line_comments_nested(single_line_comment_stripped_text, "/*", "*/");
		if (!multi_line_comment_stripped_text.has_value()) {
			std::cout << "Encountered an error while stripping multi line comments\n";
			return false;
		}

		/*
		std::cout
			<< "Multi line comment stripped text:\n"
			<< "---------------------------------------------------\n"
			<< multi_line_comment_stripped_text.value_or("Error") << "\n";
		*/

		auto outfile_data = hex_to_bin(multi_line_comment_stripped_text.value());

		/*
		std::cout << "As bytes: [ ";
		for (size_t num: outfile_data) 
			std::cout << std::hex << "0x" << num << std::dec <<  " ";
		std::cout << "]\n";
		*/

		if (!write_data_to_file(outfiles[0], outfile_data)) {
			std::cout
				<< "Error: unable to write output file\n";
			return false;
		}
		
		return true;
	}
}

int main(int argc, char **argv) {
	std::vector<std::string_view> args { argv, argv + argc };

	/*
	std::cout << "Program recieved arguments: [";
	for (auto arg: args)
		std::cout << "\"" << arg << "\" ";
	std::cout << "]\n";
	*/

	return static_cast<int>(!h2b::start(args));
}
