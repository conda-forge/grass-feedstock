@echo on
cmake -B build %CMAKE_ARGS% ^
    -DPython3_EXECUTABLE="%PYTHON%" ^
    -DWITH_OPENGL=OFF
if errorlevel 1 exit /b 1

set CMAKE_BUILD_PARALLEL_LEVEL=1
cmake --build build --config Release -j%CPU_COUNT% --verbose
if errorlevel 1 exit /b 1

cmake --install build --config Release
if errorlevel 1 exit /b 1

:: MSVC's -openmp:llvm (picked by CMake's FindOpenMP) links grass_gis.dll against
:: libomp140.x86_64.dll, a name llvm-openmp's own conda-forge package never ships
:: (it only provides libomp.dll). Alias it so the DLL can be located at runtime.
copy "%PREFIX%\Library\bin\libomp.dll" "%PREFIX%\Library\bin\libomp140.x86_64.dll"

echo "===== Installed Files ====="
dir /s /b %PREFIX%

echo "===== bin/grass.bat ====="
type %PREFIX%\Library\bin\grass.bat
echo "===== End of bin/grass.bat ====="
