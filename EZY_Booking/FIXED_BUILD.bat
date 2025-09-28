@echo off
title Fixed Java Build
color 0A

echo ========================================
echo        FIXED JAVA BUILD SCRIPT
echo ========================================
echo.
echo Finding Java automatically...
echo.

REM Try multiple Java locations
set JAVA_FOUND=0

echo Checking Program Files\Java...
if exist "C:\Program Files\Java\" (
    for /d %%i in ("C:\Program Files\Java\*") do (
        if exist "%%i\bin\java.exe" (
            echo ✓ Found Java at: %%i
            set "JAVA_HOME=%%i"
            set JAVA_FOUND=1
            goto java_found
        )
    )
)

echo Checking Eclipse Adoptium...
if exist "C:\Program Files\Eclipse Adoptium\" (
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\*") do (
        if exist "%%i\bin\java.exe" (
            echo ✓ Found Java at: %%i
            set "JAVA_HOME=%%i"
            set JAVA_FOUND=1
            goto java_found
        )
    )
)

echo Checking Program Files (x86)\Java...
if exist "C:\Program Files (x86)\Java\" (
    for /d %%i in ("C:\Program Files (x86)\Java\*") do (
        if exist "%%i\bin\java.exe" (
            echo ✓ Found Java at: %%i
            set "JAVA_HOME=%%i"
            set JAVA_FOUND=1
            goto java_found
        )
    )
)

echo Checking Microsoft OpenJDK...
if exist "C:\Program Files\Microsoft\" (
    for /d %%i in ("C:\Program Files\Microsoft\jdk*") do (
        if exist "%%i\bin\java.exe" (
            echo ✓ Found Java at: %%i
            set "JAVA_HOME=%%i"
            set JAVA_FOUND=1
            goto java_found
        )
    )
)

echo Checking JAVA_HOME environment variable...
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        echo ✓ Found Java at: %JAVA_HOME%
        set JAVA_FOUND=1
        goto java_found
    )
)

if %JAVA_FOUND%==0 (
    echo ❌ Java not found in any common location
    echo.
    echo SOLUTIONS:
    echo 1. Install Java from: https://adoptium.net/temurin/releases/
    echo 2. Or try Oracle Java: https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe
    echo 3. Make sure to install JDK (not just JRE)
    echo.
    echo After installing, run this script again.
    pause
    exit
)

:java_found
echo.
echo ========================================
echo           JAVA SETUP COMPLETE
echo ========================================
echo.
echo Java Location: %JAVA_HOME%
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo Testing Java installation...
"%JAVA_HOME%\bin\java" -version
echo.

if %errorlevel% neq 0 (
    echo ❌ Java test failed
    pause
    exit
)

echo ✓ Java is working properly!
echo.

echo ========================================
echo          BUILDING YOUR APK
echo ========================================
echo.
echo This will take 5-10 minutes for first build...
echo Please keep internet connected for downloading dependencies.
echo.

echo Cleaning previous builds...
call gradlew.bat clean --no-daemon

echo.
echo Building release APK...
call gradlew.bat assembleRelease --no-daemon --info

echo.
echo ========================================
echo            BUILD RESULT
echo ========================================
echo.

if exist "app\build\outputs\apk\release\app-release.apk" (
    echo 🎉 SUCCESS! APK built successfully!
    echo.
    echo Location: app\build\outputs\apk\release\app-release.apk
    echo.
    for %%A in ("app\build\outputs\apk\release\app-release.apk") do echo Size: %%~zA bytes
    echo.
    echo Opening folder...
    explorer "app\build\outputs\apk\release\"
    echo.
    echo ========================================
    echo        INSTALLATION INSTRUCTIONS
    echo ========================================
    echo.
    echo 1. Copy app-release.apk to your Android phone
    echo 2. On phone: Enable "Install from unknown sources"
    echo 3. Tap the APK file to install
    echo 4. Grant all permissions when asked
    echo 5. You'll see "OTP Forwarding Active" notification
    echo.
    echo NEW FEATURES:
    echo ✅ Service stays alive permanently
    echo ✅ Queues messages when offline
    echo ✅ Auto-sends when internet returns
    echo ✅ Optimized subscription validation
    echo ✅ Works on Android 5-14
    echo.
) else (
    echo ❌ Build failed!
    echo.
    echo Check the error messages above.
    echo Common solutions:
    echo 1. Make sure internet connection is stable
    echo 2. Try running as Administrator
    echo 3. Check if antivirus is blocking downloads
    echo.
)

pause