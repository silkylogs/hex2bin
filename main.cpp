#include <iostream>
#include <ranges>
#include <string>
#include <string_view>
#include <vector>

namespace h2b {
	static const struct ErrorMessages {
		std::string_view no_infiles { "Error: no infiles detected" };
		std::string_view no_outfiles { "Error: no outfiles detected" };
		std::string_view too_many_outfiles { "Error: Too many outfiles present, max allowed one (1)" };
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

		
		auto infile_data = open_files(infiles);
		auto outfile_data = hex_to_bin(infile_data);
		write_file(outfile_data);

		return true;
	}
}

int main(int argc, char **argv) {
	std::vector<std::string_view> args { argv, argv + argc };
	
	for (auto arg: args)
		std::cout << arg << "\n";

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
