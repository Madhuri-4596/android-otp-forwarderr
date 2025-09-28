@echo off
title Simple Java-Only APK Builder
color 0A

echo ========================================
echo     SIMPLE JAVA-ONLY APK BUILDER
echo ========================================
echo.
echo This method only requires Java (no Android Studio)
echo.
echo Step 1: Install Java if not already installed
echo.

java -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Java is already installed!
    goto build_apk
)

echo Java not found. Please install Java first:
echo.
echo QUICK INSTALL:
echo 1. Go to: https://adoptium.net/temurin/releases/
echo 2. Download "JDK 17 - Windows x64 - MSI"
echo 3. Install it (just click Next, Next, Install)
echo 4. Run this script again
echo.
echo Opening download page...
start https://adoptium.net/temurin/releases/
pause
exit

:build_apk
echo.
echo Step 2: Setting up build environment
echo.

REM Try to find Java installation
for /d %%i in ("%ProgramFiles%\Eclipse Adoptium\*") do (
    if exist "%%i\bin\java.exe" (
        set "JAVA_HOME=%%i"
        goto java_found
    )
)

for /d %%i in ("%ProgramFiles%\Java\*") do (
    if exist "%%i\bin\java.exe" (
        set "JAVA_HOME=%%i"
        goto java_found
    )
)

echo Java installation path not found automatically.
echo Please install Java from: https://adoptium.net/temurin/releases/
pause
exit

:java_found
echo ✓ Java found at: %JAVA_HOME%
echo.

echo Step 3: Building APK (this may take 5-10 minutes)
echo.
echo Note: First build downloads many dependencies
echo Please be patient and keep internet connected
echo.

set "PATH=%JAVA_HOME%\bin;%PATH%"

REM Clean and build
echo Cleaning previous builds...
call gradlew.bat clean --no-daemon --offline || call gradlew.bat clean --no-daemon

echo.
echo Building release APK...
call gradlew.bat assembleRelease --no-daemon --warning-mode all

echo.
if exist "app\build\outputs\apk\release\app-release.apk" (
    echo ========================================
    echo          🎉 BUILD SUCCESS! 🎉
    echo ========================================
    echo.
    echo Your APK is ready!
    echo Location: app\build\outputs\apk\release\app-release.apk
    echo.
    for %%A in ("app\build\outputs\apk\release\app-release.apk") do echo Size: %%~zA bytes
    echo.
    echo Opening APK folder...
    explorer "app\build\outputs\apk\release\"
    echo.
    echo INSTALLATION STEPS:
    echo 1. Copy app-release.apk to your Android phone
    echo 2. On phone: Settings → Security → Allow Unknown Sources
    echo 3. Tap the APK file to install
    echo 4. Grant all permissions when app asks
    echo 5. You'll see "OTP Forwarding Active" notification
    echo.
    echo NEW FEATURES IN YOUR APK:
    echo ✅ Service never gets killed by system
    echo ✅ Queues OTP messages when offline
    echo ✅ Auto-sends when internet returns
    echo ✅ Only validates subscription when needed
    echo ✅ Compatible with Android 5-14
    echo.
) else (
    echo ========================================
    echo           ❌ BUILD FAILED
    echo ========================================
    echo.
    echo Possible solutions:
    echo 1. Make sure you have stable internet (for downloading dependencies)
    echo 2. Try running as Administrator
    echo 3. Install Android Studio (easier method)
    echo.
    echo Would you like to try the Android Studio method instead?
    echo It's actually simpler and more reliable.
    echo.
    set /p choice=Type 'y' for yes, 'n' for no:
    if /i "%choice%"=="y" (
        notepad "STEP_BY_STEP_GUIDE.txt"
    )
)

echo.
pause