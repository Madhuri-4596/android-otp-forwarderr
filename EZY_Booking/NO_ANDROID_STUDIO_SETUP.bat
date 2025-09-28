@echo off
title Build APK Without Android Studio
color 0B

echo ========================================
echo   BUILD APK WITHOUT ANDROID STUDIO
echo ========================================
echo.
echo Setting up everything you need automatically...
echo This will download and install the required tools.
echo.
echo What we'll install:
echo [1] Java JDK (required to build Android apps)
echo [2] Android Command Line Tools (minimal SDK)
echo.
echo Total download: ~200MB
echo Setup time: 5-10 minutes (one time only)
echo.
echo Press any key to start automatic setup...
pause > nul

echo.
echo ========================================
echo    STEP 1: INSTALLING JAVA JDK
echo ========================================
echo.

REM Check if Java is already installed
java -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Java is already installed!
    goto skip_java
)

echo Downloading Java JDK 17...
echo (This is free and safe from Oracle)
echo.

REM Create temp directory
if not exist "%TEMP%\ezybooking_setup" mkdir "%TEMP%\ezybooking_setup"
cd "%TEMP%\ezybooking_setup"

echo Please download Java manually:
echo 1. Go to: https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe
echo 2. Download and install it
echo 3. Come back and press any key
echo.
start https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe
pause

:skip_java

echo.
echo ========================================
echo   STEP 2: SETTING UP ANDROID TOOLS
echo ========================================
echo.

REM Create SDK directory
set "ANDROID_HOME=%USERPROFILE%\android-sdk"
if not exist "%ANDROID_HOME%" mkdir "%ANDROID_HOME%"

echo Setting up minimal Android SDK...
echo Location: %ANDROID_HOME%
echo.

REM Download command line tools
echo Downloading Android Command Line Tools...
if not exist "%ANDROID_HOME%\cmdline-tools.zip" (
    echo Please download Android Command Line Tools:
    echo 1. Go to: https://developer.android.com/studio#command-tools
    echo 2. Download "Command line tools only" for Windows
    echo 3. Save as: %ANDROID_HOME%\cmdline-tools.zip
    echo 4. Come back and press any key
    echo.
    start https://developer.android.com/studio#command-tools
    pause
)

REM Extract tools
echo Extracting Android tools...
if exist "%ANDROID_HOME%\cmdline-tools.zip" (
    powershell -Command "Expand-Archive -Path '%ANDROID_HOME%\cmdline-tools.zip' -DestinationPath '%ANDROID_HOME%' -Force"
    echo ✓ Tools extracted
)

echo.
echo ========================================
echo   STEP 3: INSTALLING SDK COMPONENTS
echo ========================================
echo.

REM Set environment variables
set "PATH=%ANDROID_HOME%\cmdline-tools\bin;%PATH%"
set "PATH=%ANDROID_HOME%\platform-tools;%PATH%"

echo Installing required Android SDK components...
echo This may take a few minutes...
echo.

REM Install SDK components (if sdkmanager exists)
if exist "%ANDROID_HOME%\cmdline-tools\bin\sdkmanager.bat" (
    echo Installing Android SDK Platform...
    call "%ANDROID_HOME%\cmdline-tools\bin\sdkmanager.bat" "platforms;android-34"

    echo Installing Build Tools...
    call "%ANDROID_HOME%\cmdline-tools\bin\sdkmanager.bat" "build-tools;34.0.0"

    echo ✓ SDK components installed
) else (
    echo SDK manager not found. Manual setup required.
)

echo.
echo ========================================
echo      STEP 4: BUILDING YOUR APK
echo ========================================
echo.

cd /d "%~dp0"

echo Setting environment variables...
set "JAVA_HOME=%ProgramFiles%\Java\jdk-17"
if not exist "%JAVA_HOME%" (
    for /d %%i in ("%ProgramFiles%\Java\jdk*") do set "JAVA_HOME=%%i"
)

echo JAVA_HOME: %JAVA_HOME%
echo ANDROID_HOME: %ANDROID_HOME%
echo.

if exist "%JAVA_HOME%\bin\java.exe" (
    echo ✓ Java found at: %JAVA_HOME%
    echo Building APK...
    echo.

    set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\cmdline-tools\bin;%ANDROID_HOME%\platform-tools;%PATH%"

    call gradlew.bat clean assembleRelease

    if exist "app\build\outputs\apk\release\app-release.apk" (
        echo.
        echo ========================================
        echo           🎉 SUCCESS! 🎉
        echo ========================================
        echo.
        echo Your APK is ready at:
        echo app\build\outputs\apk\release\app-release.apk
        echo.
        explorer "app\build\outputs\apk\release\"
    ) else (
        echo Build failed. You may need to install Android Studio after all.
    )
) else (
    echo ❌ Java installation not found.
    echo Please install Java JDK 17 and run this script again.
    echo Download from: https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe
)

echo.
pause