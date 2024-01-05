@echo off

rem Set this value to the location of rc.exe under the VC directory
set rc_directory=C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64
set kit_directory=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64

rem Set this value to the location of ml64.exe under the VC directory
set ml_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

rem Set this value to the location of link.exe under the VC directory
set link_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

rem General settings
set executable_name="hex2bin.exe"
set resource_compiler="%rc_directory%\rc.exe"
set assembler="%ml_directory%\ml64.exe"
set linker="%link_directory%\link.exe"
set assembler_error_log="assembler_errors.txt"

rem Libraries
set lib_kernel32="%kit_directory%\kernel32.lib"
set lib_user32="%kit_directory%\user32.lib"
set lib_winmm="%kit_directory%\winmm.lib"

mkdir bin
pushd bin
%resource_compiler% /nologo ..\resource.rc
%assembler% /nologo /c /Cp /Cx /Fm /FR /W2 /Zd /Zf /Zi /Ta ..\main.asm > %assembler_error_log%

%linker% ^
main.obj ..\resource.res %lib_kernel32% %lib_user32% %lib_winmm% ^
/nologo /opt:ref /opt:noicf /largeaddressaware:no ^
/entry:Startup /machine:x64 /debug:full ^
/map /out:%executable_name% /PDB:main.pdb /subsystem:console

echo Errors from %assembler_error_log%, if any:
type %assembler_error_log%

popd
