# hex2bin

This is a small (<500 SLOC) hexadecimal to binary converter written
to try and get aquainted with modern (~2020) C++

## Usage

### Command line arugments
- A nonzero number of input parameters are accepted
- Only one output filename is accepted, which is overwritten if it exists
An example of correct usage:
`hex2bin object_file_1.bin object_file_2.bin -o final_out.bin`
This concatenates all input files and performs the conversion on its result

### Evaluation
- The program accepts input in a free form manner
  (whitespace/newlines/grouping do not matter)
```
// These all evaluate to the same arrangement of bytes
cafebabe
cafe babe
ca fe ba be
c a f e b a b e
```

- If the number of characters in the file is not an even number,
  a zero is automatically appended to the last letter in order
  to make it a proper byte
```
fe dc ba 98
76 54 32 1  // `0` gets appended to the left of `1` here
```

- Depending on the implementation, either invalid characters other than the following
  `0123456789 abcdef ABCDEF`, ` `, `\t`, `\r\n` get ignored or raise an error

### Comments
Unlike other converters, hex2bin accepts comments to
open the gates to a more human friendly way of labelling data

#### Single line comments
```
///// ---------- CONSTANTS ----------- /////
// These are some important 4 bit constants for some imaginary program
40 49 0f db // Pi
40 2d f8 54 // e
00 00 00 2a // The answer of life, the universe, and everything
///// ---------- CONSTANTS ----------- /////
```

#### Multi line comments
```
/*
	Look,
	mom
	/*
		My comments
		can be
		multi nested!

		An ideal usecase for this would be
		automatic documentation generation
	*/
*/
```

## Compilation
As of now, premake5 is used to compile this program.
Run the following (on a windows machine, in the x64 native tools command prompt) to compile:
```
premake5 vs2019
msbuild
```
The resulting executable should be in `.\bin\Debug\`
