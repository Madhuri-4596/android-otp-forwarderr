@echo off
title Fix Android Studio Java Path
color 0A

echo ========================================
echo   FIXING ANDROID STUDIO JAVA PATH
echo ========================================
echo.

echo Looking for Android Studio Java...
echo.

REM Check common Android Studio Java locations
if exist "C:\Program Files\Android\Android Studio\jre\" (
    echo Found Android Studio JRE: C:\Program Files\Android\Android Studio\jre\
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jre"
    goto found_java
)

if exist "C:\Program Files\Android\Android Studio\jbr\" (
    echo Found Android Studio JBR: C:\Program Files\Android\Android Studio\jbr\
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
    goto found_java
)

if exist "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\" (
    echo Found Android SDK tools
    for /d %%i in ("%LOCALAPPDATA%\Android\Sdk\cmdline-tools\*") do (
        if exist "%%i\bin\java.exe" (
            set "JAVA_HOME=%%i"
            goto found_java
        )
    )
)

echo Searching Program Files...
for /d %%i in ("C:\Program Files\Android\*") do (
    if exist "%%i\jre\bin\java.exe" (
        echo Found Java at: %%i\jre
        set "JAVA_HOME=%%i\jre"
        goto found_java
    )
    if exist "%%i\jbr\bin\java.exe" (
        echo Found Java at: %%i\jbr
        set "JAVA_HOME=%%i\jbr"
        goto found_java
    )
)

echo Java not found in Android Studio folders.
echo.
echo SOLUTION: Use Android Studio directly
echo 1. Open Android Studio
echo 2. Open this project: C:\Users\Dell\EZY_Booking
echo 3. Go to Build → Generate Signed Bundle/APK
echo 4. Choose APK → Release
echo.
pause
exit

:found_java
echo ✓ Found Java at: %JAVA_HOME%
echo.
echo Setting JAVA_HOME and building APK...
set PATH=%JAVA_HOME%\bin;%PATH%

echo Testing Java...
"%JAVA_HOME%\bin\java" -version

echo.
echo Building APK with correct Java path...
echo.
call gradlew.bat clean assembleRelease

if exist "app\build\outputs\apk\release\app-release.apk" (
    echo.
    echo ========================================
    echo           BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Your APK is ready at:
    echo app\build\outputs\apk\release\app-release.apk
    echo.
    explorer "app\build\outputs\apk\release\"
) else (
    echo.
    echo Build still failed. Let's use Android Studio GUI instead:
    echo 1. Open Android Studio
    echo 2. Open project: %cd%
    echo 3. Build → Generate Signed Bundle/APK → APK → Release
)

pause