@echo off
title Install Java 17 and Build APK
color 0B

echo ========================================
echo    INSTALL JAVA 17 AND BUILD APK
echo ========================================
echo.
echo Java 25 is too new for Android development.
echo Let's install Java 17 LTS (the standard for Android projects)
echo.

echo Current Java version:
java -version
echo.

echo SOLUTION: Install Java 17 LTS alongside Java 25
echo This won't remove Java 25 - you'll have both versions.
echo.

echo ========================================
echo      STEP 1: DOWNLOAD JAVA 17
echo ========================================
echo.

echo Opening Java 17 download page...
echo Please download Java 17 LTS (Eclipse Temurin)
echo.
echo IMPORTANT:
echo 1. Choose "JDK 17 LTS"
echo 2. Choose "Windows x64"
echo 3. Choose ".msi" package (easiest to install)
echo 4. Install it (keep default settings)
echo.

start https://adoptium.net/temurin/releases/?version=17

echo Press any key after you've installed Java 17...
pause

echo.
echo ========================================
echo      STEP 2: FIND JAVA 17
echo ========================================
echo.

echo Looking for Java 17 installation...
echo.

set JAVA17_FOUND=0

REM Look for Java 17 in common locations
if exist "C:\Program Files\Eclipse Adoptium\jdk-17*" (
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do (
        if exist "%%i\bin\java.exe" (
            set "JAVA17_HOME=%%i"
            set JAVA17_FOUND=1
            echo ✓ Found Java 17 at: %%i
            goto java17_found
        )
    )
)

if exist "C:\Program Files\Java\jdk-17*" (
    for /d %%i in ("C:\Program Files\Java\jdk-17*") do (
        if exist "%%i\bin\java.exe" (
            set "JAVA17_HOME=%%i"
            set JAVA17_FOUND=1
            echo ✓ Found Java 17 at: %%i
            goto java17_found
        )
    )
)

if %JAVA17_FOUND%==0 (
    echo ❌ Java 17 not found!
    echo.
    echo Please make sure you:
    echo 1. Downloaded Java 17 LTS from: https://adoptium.net/temurin/releases/?version=17
    echo 2. Chose the .msi installer
    echo 3. Completed the installation
    echo.
    echo Then run this script again.
    pause
    exit
)

:java17_found
echo.
echo ========================================
echo     STEP 3: BUILD WITH JAVA 17
echo ========================================
echo.

echo Setting up Java 17 for this build...
set "JAVA_HOME=%JAVA17_HOME%"
set "PATH=%JAVA17_HOME%\bin;%PATH%"

echo Testing Java 17...
"%JAVA17_HOME%\bin\java" -version
echo.

if %errorlevel% neq 0 (
    echo ❌ Java 17 test failed
    pause
    exit
)

echo ✓ Java 17 is working perfectly!
echo.

echo Clearing Gradle cache (to fix compatibility issues)...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul

echo.
echo Building APK with Java 17...
echo This will take 5-10 minutes...
echo.

echo Step 1: Clean build...
call gradlew.bat clean --no-daemon

echo.
echo Step 2: Build release APK...
call gradlew.bat assembleRelease --no-daemon

echo.
echo ========================================
echo            FINAL RESULT
echo ========================================
echo.

if exist "app\build\outputs\apk\release\app-release.apk" (
    echo 🎉🎉🎉 FINALLY SUCCESS! 🎉🎉🎉
    echo.
    echo Built with Java 17 LTS - the standard for Android!
    echo.
    echo Your improved APK is ready:
    echo Location: app\build\outputs\apk\release\app-release.apk
    echo.
    for %%A in ("app\build\outputs\apk\release\app-release.apk") do (
        echo Size: %%~zA bytes
        echo Created: %%~tA
    )
    echo.
    echo Opening APK folder...
    explorer "app\build\outputs\apk\release\"
    echo.
    echo ========================================
    echo      📱 YOUR NEW APK FEATURES
    echo ========================================
    echo.
    echo ✅ PERSISTENT FOREGROUND SERVICE
    echo    - Never gets killed by Android system
    echo    - Shows "OTP Forwarding Active" notification
    echo.
    echo ✅ OFFLINE MESSAGE QUEUING
    echo    - Saves OTP messages when no internet
    echo    - Local database with retry mechanism
    echo.
    echo ✅ NETWORK MONITORING & AUTO-RETRY
    echo    - Detects when internet comes back
    echo    - Automatically sends queued messages
    echo.
    echo ✅ OPTIMIZED SUBSCRIPTION VALIDATION
    echo    - Only checks when app opens or settings change
    echo    - No more constant API calls
    echo.
    echo ✅ ANDROID 5-14 COMPATIBILITY
    echo    - Fixed installation issues on Android 11+
    echo    - Works on all modern devices
    echo.
    echo ✅ BATTERY OPTIMIZATION HANDLING
    echo    - Requests exemption from battery saving
    echo    - Service survives aggressive power management
    echo.
    echo INSTALLATION INSTRUCTIONS:
    echo 1. Copy app-release.apk to your Android phone
    echo 2. Enable "Install from unknown sources"
    echo 3. Tap APK to install
    echo 4. Grant ALL permissions when asked
    echo 5. Open app and configure your settings
    echo 6. Service will start automatically!
    echo.
) else (
    echo ❌ Build still failed even with Java 17
    echo.
    echo This might be a deeper issue. Let's try the simplest solution:
    echo.
    echo EASIEST SOLUTION: Use Android Studio
    echo 1. Install Android Studio from: https://developer.android.com/studio
    echo 2. Open this project in Android Studio
    echo 3. Build → Generate Signed Bundle/APK → APK → Release
    echo.
    echo Android Studio handles all Java/Gradle compatibility automatically.
    echo.
    start https://developer.android.com/studio
)

pause