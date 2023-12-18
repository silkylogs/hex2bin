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
	
	
	std::optional<std::vector<uint8_t>>
	hex_to_bin(std::string hex);
	
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
		std::cout
			<< "Entered text:\n"
			<< "---------------------------------------------------\n"
			<< infile_text_data.value_or("No text found") << "\n";
		
		auto single_line_comment_stripped_text =
			strip_single_line_comments(infile_text_data.value(), "//");
		std::cout
			<< "Single line comment stripped text:\n"
			<< "---------------------------------------------------\n"
			<< single_line_comment_stripped_text << "\n";

		/*
		auto multi_line_comment_stripped_text =
			strip_multi_line_comments(single_line_comment_stripped_text, "\/*", "*\/");
		std::cout
			<< "Multi line comment stripped text:\n"
			<< "---------------------------------------------------\n"
			<< multi_line_comment_stripped_text << "\n";

		// auto outfile_data = hex_to_bin(infile_text_data.value());
		// write_file(outfile_data);
		*/
		
		return true;
	}
}

int main(int argc, char **argv) {
	std::vector<std::string_view> args { argv, argv + argc };

	std::cout << "Program recieved arguments: [";
	for (auto arg: args)
		std::cout << "\"" << arg << "\" ";
	std::cout << "]\n";

	return static_cast<int>(!h2b::start(args));
	
	/*
    auto const ints = {0, 1, 2, 3, 4, 5};
    auto even = [](int i) { return 0 == i % 2; };
    auto square = [](int i) { return i * i; };
 
    // the "pipe" syntax of composing the views:
    for (int i : ints
		 | std::views::filter(even)
		 | std::views::transform(square))
        std::cout << i << ' ';
 
    std::cout << '\n';
	*/
}
