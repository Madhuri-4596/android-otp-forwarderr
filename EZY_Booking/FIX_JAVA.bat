@echo off
title Java Setup Fixer
color 0C

echo ========================================
echo         JAVA SETUP FIXER
echo ========================================
echo.

echo Looking for Java installations...
echo.

REM Check common Java locations
if exist "C:\Program Files\Java\" (
    echo Found Java in: C:\Program Files\Java\
    dir "C:\Program Files\Java\" /b
    echo.
)

if exist "C:\Program Files (x86)\Java\" (
    echo Found Java in: C:\Program Files (x86)\Java\
    dir "C:\Program Files (x86)\Java\" /b
    echo.
)

REM Check if java command works
java -version 2>nul
if %errorlevel% equ 0 (
    echo Java is working! ✓
    echo.
    echo JAVA_HOME might just need to be set.
    echo Try running the build again.
) else (
    echo Java command not found ✗
    echo.
    echo SOLUTIONS:
    echo 1. Install Java JDK from: https://www.oracle.com/java/technologies/javase-downloads.html
    echo 2. OR install Android Studio from: https://developer.android.com/studio
    echo.
    echo After installation, run ONE_CLICK_BUILD.bat again
)

echo.
pause