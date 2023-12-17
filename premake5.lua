-- premake5.lua
workspace "Hex2Bin"
   configurations { "Debug", "Release" }

project "Hex2Bin"
   kind "ConsoleApp"
   language "C++"
   targetdir "bin/%{cfg.buildcfg}"
   architecture "x86_64"
   cppdialect "C++latest"

   files { "*.cpp" }

   filter "configurations:Debug"
      defines { "DEBUG" }
      symbols "On"

   filter "configurations:Release"
      defines { "NDEBUG" }
      optimize "On"