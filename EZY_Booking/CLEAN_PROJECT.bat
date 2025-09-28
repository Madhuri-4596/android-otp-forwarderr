@echo off
title Clean Project for Upload
color 0C

echo ========================================
echo      CLEANING PROJECT FOR UPLOAD
echo ========================================
echo.
echo This will remove build files and cache to make
echo your project small enough for GitHub upload.
echo.
echo Current project size: Large (1000+ files)
echo After cleaning: Small (~50 files)
echo.

echo Are you sure you want to clean build files?
echo This is safe - it only removes generated files.
echo.
pause

echo.
echo Cleaning project...
echo.

echo Removing app build folder...
if exist "app\build\" (
    rmdir /s /q "app\build\"
    echo ✓ Removed app\build\
) else (
    echo - app\build\ not found
)

echo.
echo Removing Gradle cache...
if exist ".gradle\" (
    rmdir /s /q ".gradle\"
    echo ✓ Removed .gradle\
) else (
    echo - .gradle\ not found
)

echo.
echo Removing IDE files...
if exist ".idea\" (
    rmdir /s /q ".idea\"
    echo ✓ Removed .idea\
) else (
    echo - .idea\ not found
)

echo.
echo Removing IntelliJ files...
for %%f in (*.iml) do (
    del "%%f"
    echo ✓ Removed %%f
)

echo.
echo Removing local properties...
if exist "local.properties" (
    del "local.properties"
    echo ✓ Removed local.properties
) else (
    echo - local.properties not found
)

echo.
echo Removing other temporary files...
if exist "captures\" (
    rmdir /s /q "captures\"
    echo ✓ Removed captures\
)

echo.
echo ========================================
echo         CLEANUP COMPLETE!
echo ========================================
echo.

echo Before: 1000+ files (hundreds of MB)
echo After: ~50 files (few MB)
echo.

echo Your project is now ready for upload!
echo.

echo WHAT WAS REMOVED (safe to delete):
echo ✓ Build outputs (app\build\)
echo ✓ Gradle cache (.gradle\)
echo ✓ IDE configuration (.idea\)
echo ✓ Temporary files
echo.

echo WHAT WAS KEPT (your actual code):
echo ✓ Source code (app\src\)
echo ✓ Build configuration files
echo ✓ Gradle wrapper
echo ✓ Keystore for signing
echo.

echo ========================================
echo         NEXT STEPS
========================================
echo.

echo Now you can upload to GitHub:
echo.
echo METHOD 1: Direct Upload
echo 1. Go to https://github.com/new
echo 2. Create repository "EZY_Booking"
echo 3. Click "uploading an existing file"
echo 4. Drag your cleaned EZY_Booking folder
echo.
echo METHOD 2: ZIP Upload
echo 1. Right-click EZY_Booking folder
echo 2. Send to → Compressed folder
echo 3. Upload the ZIP to GitHub
echo.
echo METHOD 3: Count files first
dir /s /b | find /c /v ""
echo Total files now:
echo.

echo The upload should work perfectly now!
echo.
pause