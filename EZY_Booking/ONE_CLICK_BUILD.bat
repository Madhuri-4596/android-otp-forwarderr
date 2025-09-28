@echo off
title EZY Booking APK Builder
color 0A

echo ========================================
echo    EZY BOOKING - NEW APK BUILDER
echo ========================================
echo.
echo Building APK with ALL improvements:
echo [+] Persistent foreground service
echo [+] Offline message queuing
echo [+] Network monitoring
echo [+] Auto-retry mechanism
echo [+] Optimized subscription validation
echo [+] Android 5-14 compatibility
echo.

echo Cleaning previous builds...
call gradlew.bat clean --quiet

echo.
echo Building signed release APK...
call gradlew.bat assembleRelease --quiet

echo.
if exist "app\build\outputs\apk\release\app-release.apk" (
    echo ========================================
    echo           BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Your new APK is ready at:
    echo app\build\outputs\apk\release\app-release.apk
    echo.
    echo File size:
    for %%A in ("app\build\outputs\apk\release\app-release.apk") do echo %%~zA bytes
    echo.
    echo COPY THIS APK TO YOUR ANDROID PHONE AND INSTALL IT
    echo.
    echo New features included:
    echo - Service stays alive in background permanently
    echo - OTP messages queued when offline
    echo - Auto-send when internet returns
    echo - Battery optimization exemption
    echo - Works on Android 5 to Android 14
    echo.
    pause
    explorer "app\build\outputs\apk\release\"
) else (
    echo ========================================
    echo           BUILD FAILED!
    echo ========================================
    echo.
    echo Please install Android Studio first:
    echo https://developer.android.com/studio
    echo.
    echo Then run this script again.
    pause
)