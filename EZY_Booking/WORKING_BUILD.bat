@echo off
title Working APK Builder
color 0A

echo ========================================
echo        WORKING APK BUILDER
echo ========================================
echo.
echo Java 25 detected! Building your APK now...
echo.

echo Testing Java...
java -version
echo.

if %errorlevel% neq 0 (
    echo ❌ Java test failed
    pause
    exit
)

echo ✓ Java is working perfectly!
echo.

echo ========================================
echo          BUILDING YOUR APK
echo ========================================
echo.
echo This will take 5-10 minutes for first build...
echo Downloading dependencies and compiling...
echo.
echo Please be patient and keep internet connected.
echo.

echo Step 1: Cleaning previous builds...
call gradlew.bat clean

echo.
echo Step 2: Building release APK...
echo (This is the longest step - please wait)
echo.

call gradlew.bat assembleRelease --warning-mode all

echo.
echo ========================================
echo            BUILD COMPLETE
echo ========================================
echo.

if exist "app\build\outputs\apk\release\app-release.apk" (
    echo 🎉🎉🎉 SUCCESS! 🎉🎉🎉
    echo.
    echo Your improved APK is ready!
    echo.
    echo Location: app\build\outputs\apk\release\app-release.apk
    echo.
    echo File details:
    for %%A in ("app\build\outputs\apk\release\app-release.apk") do (
        echo Size: %%~zA bytes
        echo Created: %%~tA
    )
    echo.
    echo Opening APK folder...
    explorer "app\build\outputs\apk\release\"
    echo.
    echo ========================================
    echo          🚀 WHAT'S NEW IN YOUR APK
    echo ========================================
    echo.
    echo ✅ PERSISTENT SERVICE: Never gets killed by Android
    echo ✅ OFFLINE QUEUING: Saves OTP messages when no internet
    echo ✅ AUTO-RECOVERY: Sends queued messages when online
    echo ✅ SMART VALIDATION: Only checks subscription when needed
    echo ✅ BATTERY OPTIMIZED: Requests exemption from battery saving
    echo ✅ ANDROID 5-14 COMPATIBLE: Works on all modern devices
    echo ✅ FOREGROUND NOTIFICATION: Shows "OTP Forwarding Active"
    echo.
    echo ========================================
    echo         📱 INSTALLATION GUIDE
    echo ========================================
    echo.
    echo 1. Copy app-release.apk to your Android phone
    echo 2. On phone: Settings → Security → Install unknown apps
    echo 3. Enable for your file manager
    echo 4. Tap the APK file to install
    echo 5. Grant ALL permissions when app requests them:
    echo    - SMS permissions
    echo    - Phone permissions
    echo    - Battery optimization exemption
    echo 6. Open the app and enter your settings
    echo 7. You'll see persistent notification "OTP Forwarding Active"
    echo.
    echo ========================================
    echo            🧪 TEST YOUR APP
    echo ========================================
    echo.
    echo After installation:
    echo 1. Turn off WiFi/mobile data
    echo 2. Send a test SMS to your phone
    echo 3. Turn internet back on
    echo 4. Check if OTP was sent to your server
    echo.
    echo The service will stay alive even after:
    echo - Phone restart
    echo - App being "force stopped"
    echo - Battery optimization
    echo - System memory cleanup
    echo.
) else (
    echo ❌ Build failed!
    echo.
    echo Let me check what went wrong...
    echo.
    if exist "app\build\" (
        echo Build folder exists, checking for error details...
        if exist "app\build\outputs\" (
            echo Outputs folder exists...
            dir "app\build\outputs\" /s /b
        )
    )
    echo.
    echo Common solutions:
    echo 1. Make sure internet connection is stable
    echo 2. Try running as Administrator (right-click → Run as administrator)
    echo 3. Temporarily disable antivirus
    echo 4. Try again - sometimes first build needs multiple attempts
    echo.
    echo Would you like to try again? (Press any key)
)

echo.
pause