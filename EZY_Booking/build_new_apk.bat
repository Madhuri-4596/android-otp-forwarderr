@echo off
echo Building New EZY Booking APK with improvements...
echo.

echo Cleaning previous builds...
call gradlew.bat clean

echo.
echo Building release APK with signing...
call gradlew.bat assembleRelease

echo.
if exist "app\build\outputs\apk\release\app-release.apk" (
    echo SUCCESS! New APK created at:
    echo app\build\outputs\apk\release\app-release.apk
    echo.
    echo Copy this APK to your Android phone and install it.
    echo The new version includes:
    echo - Persistent foreground service
    echo - Offline message queuing
    echo - Network monitoring and auto-retry
    echo - Optimized subscription validation
    echo - Android 5-14 compatibility
    pause
) else (
    echo BUILD FAILED! Check the error messages above.
    echo You may need to install Android Studio first.
    pause
)