@echo off

REM Set this value to the location of rc.exe under the VC directory
set rc_directory=C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64
set kit_directory=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64

REM Set this value to the location of cl.exe under the VC directory
set cc_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

REM Set this value to the location of link.exe under the VC directory
set linker_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

REM Qouted paths
set include_dir_windows_um="C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um"
set include_dir_windows_shared="C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared"
set include_dir_windows_ucrt="C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt"
set include_dir_windows_winrt="C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\winrt"
set include_dir_windows_cppwinrt="C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\cppwinrt"
set include_dir_msvc="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\include"
set lib_dir_spectre=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\lib\spectre\onecore\x64

REM General settings
set executable_name="hex2bin.exe"
set resource_compiler="%rc_directory%\rc.exe"
set compiler="%cc_directory%\cl.exe"
set linker="%linker_directory%\link.exe"
set compiler_error_log="compiler_errors.txt"

REM Includes
set compiler_includes_flag=^
/I%include_dir_msvc% ^
/I%include_dir_windows_um% ^
/I%include_dir_windows_shared% ^
/I%include_dir_windows_ucrt% ^
/I%include_dir_windows_winrt% ^
/I%include_dir_windows_cppwinrt%

REM Libraries
set lib_kernel32="%kit_directory%\kernel32.lib"
set libs=%lib_kernel32% 

REM compiler flags
set cc_flags=^
%compiler_includes_flag% ^
/nologo /c /utf-8 /std:c++latest ^
/W4 /fp:fast /fp:except- /GR- /EHa- /Oi /GL /GS-

set linker_flags_1=^
main.obj ..\resource.res %libs% /libpath:"%lib_dir_spectre%" ^
/nologo /opt:ref /opt:noicf /largeaddressaware:no ^
/entry:Startup /machine:x64 /debug:full ^
/map /out:%executable_name% /PDB:main.pdb /subsystem:console ^
/nodefaultlib

set linker_flags_2=^
main.obj ..\resource.res %libs% /libpath:"%lib_dir_spectre%" ^
/nologo /opt:ref ^
/entry:Startup /debug:none ^
/map /out:%executable_name% /subsystem:console ^
/nodefaultlib /LTCG /incremental:no

mkdir bin
pushd bin
%resource_compiler% /nologo ..\resource.rc
%compiler% %cc_flags% ..\main.cpp > %compiler_error_log%
%linker% %linker_flags_2%


echo Errors from %compiler_error_log%, if any:
type %compiler_error_log%

popd
