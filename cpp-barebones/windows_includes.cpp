#pragma once
//#include <Windows.h>

constexpr auto STD_INPUT_HANDLE = static_cast<std::uint32_t>(-10);
constexpr auto STD_OUTPUT_HANDLE = static_cast<std::uint32_t>(-11);
constexpr auto STD_ERROR_HANDLE = static_cast<std::uint32_t>(-12);

extern "C" void *GetStdHandle(u32);
extern "C" void WriteConsoleA(void *, const char *, int, void *, void *);
extern "C" void ExitProcess(int);
extern "C" char *GetCommandLineA();
