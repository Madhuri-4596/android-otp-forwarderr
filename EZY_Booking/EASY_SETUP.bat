@echo off
title EZY Booking - Easy Setup
color 0B

echo ========================================
echo     EZY BOOKING - EASY SETUP
echo ========================================
echo.
echo This will help you get everything working!
echo.

echo Step 1: Checking Java...
java -version 2>nul
if %errorlevel% equ 0 (
    echo ✓ Java is installed and working!
    echo.
    echo Ready to build APK!
    echo Running build now...
    echo.
    call ONE_CLICK_BUILD.bat
) else (
    echo ✗ Java not found or not working
    echo.
    echo QUICK FIX - Choose one:
    echo.
    echo Option A: Install Java JDK
    echo   1. Go to: https://www.oracle.com/java/technologies/javase-downloads.html
    echo   2. Download Java JDK 11 or 17
    echo   3. Install it
    echo   4. Run this script again
    echo.
    echo Option B: Install Android Studio (Recommended)
    echo   1. Go to: https://developer.android.com/studio
    echo   2. Download and install Android Studio
    echo   3. It includes Java automatically
    echo   4. Run this script again
    echo.
    echo After installing either option, your APK will build successfully!
    echo.
    echo Would you like me to open the download pages for you?
    set /p choice=Type 'j' for Java, 'a' for Android Studio, or 'n' for no:

    if /i "%choice%"=="j" (
        start https://www.oracle.com/java/technologies/javase-downloads.html
        echo Opening Java download page...
    )
    if /i "%choice%"=="a" (
        start https://developer.android.com/studio
        echo Opening Android Studio download page...
    )
)

echo.
pause