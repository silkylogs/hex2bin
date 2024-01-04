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

REM %linker% ^
REM main.obj resource.res ^
REM /nologo /opt:ref /opt:noicf /largeaddressaware:no ^
REM /entry:Startup /machine:x64 /debug:full ^
REM /map /out:main.exe /PDB:main.pdb /subsystem:console ^
REM %kit_directory%\kernel32.lib ^
REM %kit_directory%\user32.lib ^
REM %kit_directory%\winmm.lib 

%linker% ^
main.obj kernel32.lib user32.lib winmm.lib ^
/nologo /opt:ref /opt:noicf /largeaddressaware:no ^
/entry:Startup /machine:x64 /debug:full ^
/map /out:main.exe /PDB:main.pdb /subsystem:console 

echo Errors from %assembler_error_log%, if any:
type %assembler_error_log%
