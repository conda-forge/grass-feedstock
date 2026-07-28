@echo on
cmake -B build %CMAKE_ARGS% ^
    -DPython3_EXECUTABLE="%PYTHON%" ^
    -DWITH_OPENGL=OFF ^
    -DOpenMP_C_FLAGS="/openmp" ^
    -DOpenMP_CXX_FLAGS="/openmp"
if errorlevel 1 exit /b 1

set CMAKE_BUILD_PARALLEL_LEVEL=1
cmake --build build --config Release -j%CPU_COUNT% --verbose
if errorlevel 1 exit /b 1

cmake --install build --config Release
if errorlevel 1 exit /b 1

echo "===== Installed Files ====="
dir /s /b %PREFIX%

echo "===== bin/grass.bat ====="
type %PREFIX%\Library\bin\grass.bat
echo "===== End of bin/grass.bat ====="
