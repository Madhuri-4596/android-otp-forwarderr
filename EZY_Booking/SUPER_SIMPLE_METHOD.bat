@echo off
title Super Simple APK Builder
color 0E

echo ========================================
echo      SUPER SIMPLE APK BUILDER
echo ========================================
echo.
echo Don't worry! I'll make this super easy for you.
echo.
echo EASIEST METHOD:
echo.
echo 1. I'll try to fix the Java path automatically
echo 2. Then build your APK
echo 3. Then open the folder with your APK
echo.
echo Press any key to start...
pause > nul

echo.
echo Step 1: Looking for Android Studio Java...
echo.

REM Try multiple Android Studio Java locations
set FOUND_JAVA=0

if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Studio\jbr"
    set FOUND_JAVA=1
    echo ✓ Found Java in Android Studio JBR
)

if %FOUND_JAVA%==0 if exist "C:\Program Files\Android\Android Studio\jre\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jre"
    set FOUND_JAVA=1
    echo ✓ Found Java in Android Studio JRE
)

if %FOUND_JAVA%==0 (
    echo ❌ Couldn't find Android Studio Java automatically
    echo.
    echo NO PROBLEM! Here's what to do:
    echo.
    echo METHOD A: Use Android Studio (Recommended)
    echo   1. Open Android Studio from Start Menu
    echo   2. Click "Open an existing project"
    echo   3. Choose this folder: %cd%
    echo   4. Wait for sync to finish
    echo   5. Go to Build → Generate Signed Bundle/APK
    echo   6. Choose APK → Release → Finish
    echo.
    echo METHOD B: Install Java separately
    echo   1. Go to: https://www.oracle.com/java/technologies/javase-downloads.html
    echo   2. Download Java JDK 11 or 17
    echo   3. Install it
    echo   4. Run this script again
    echo.
    echo Which method do you prefer?
    echo Press 'A' for Android Studio or 'J' for Java download
    choice /c AJ /n /m "Choose A or J: "

    if errorlevel 2 (
        start https://www.oracle.com/java/technologies/javase-downloads.html
        echo Opening Java download page...
    )
    if errorlevel 1 (
        echo Opening instructions for Android Studio method...
        notepad "STEP_BY_STEP_GUIDE.txt"
    )
    pause
    exit
)

echo.
echo Step 2: Setting up Java environment...
set PATH=%JAVA_HOME%\bin;%PATH%

echo.
echo Step 3: Building your APK...
echo (This may take 2-3 minutes)
echo.

call gradlew.bat clean assembleRelease

echo.
if exist "app\build\outputs\apk\release\app-release.apk" (
    echo ========================================
    echo          🎉 SUCCESS! 🎉
    echo ========================================
    echo.
    echo Your new APK is ready!
    echo Location: app\build\outputs\apk\release\app-release.apk
    echo.
    echo Opening the folder now...
    explorer "app\build\outputs\apk\release\"
    echo.
    echo NEXT STEPS:
    echo 1. Copy app-release.apk to your Android phone
    echo 2. Install it (allow unknown sources if asked)
    echo 3. Grant permissions when the app requests them
    echo 4. You'll see "OTP Forwarding Active" notification
    echo.
    echo Your app now has all the improvements:
    echo ✅ Stays alive in background permanently
    echo ✅ Queues messages when offline
    echo ✅ Auto-sends when internet returns
    echo ✅ Works on Android 5-14
    echo.
) else (
    echo ❌ Build failed. Let's use Android Studio instead.
    echo.
    echo I'll open the step-by-step guide for you:
    notepad "STEP_BY_STEP_GUIDE.txt"
)

pause