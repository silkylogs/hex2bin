@echo off

rem Set this value to the location of rc.exe under the VC directory
set rc_directory=C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64
set kit_directory=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64

rem Set this value to the location of ml64.exe under the VC directory
set ml_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

rem Set this value to the location of link.exe under the VC directory
set link_directory=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

set assembler_error_log=assembler_errors.txt
set resource_compiler="%rc_directory%\rc.exe"
set assembler="%ml_directory%\ml64.exe"
set linker="%link_directory%\link.exe"

%resource_compiler% /nologo resource.rc

%assembler% /nologo /c /Cp /Cx /Fm /FR /W2 /Zd /Zf /Zi /Ta main.asm > %assembler_error_log%

%linker% ^
main.obj resource.res ^
/nologo /debug:none /opt:ref /opt:noicf /largeaddressaware:no ^
/def:DXSample.def /entry:Startup /machine:x64 /debug:full ^
/map /out:main.exe /PDB:main.pdb /subsystem:windows,6.0 ^
%kit_directory%\kernel32.lib ^
%kit_directory%\user32.lib ^
%kit_directory%\d3d11.lib ^
%kit_directory%\d3dcompiler.lib ^
%kit_directory%\winmm.lib 
REM ^ DXSampleMath.lib

echo Errors from %assembler_error_log%, if any:
type %assembler_error_log%
