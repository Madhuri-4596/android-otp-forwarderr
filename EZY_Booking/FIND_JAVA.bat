@echo off
title Find Java Installation
color 0E

echo ========================================
echo         FINDING JAVA INSTALLATION
echo ========================================
echo.

echo Searching for Java in common locations...
echo.

REM Test if java command works
echo Testing java command...
java -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Java command works!
    java -version
    echo.
    echo Java is properly installed. The build script should work.
    echo Try running SIMPLE_JAVA_ONLY.bat again.
    pause
    exit
)

echo ❌ Java command not found in PATH
echo.

echo Searching in Program Files...
if exist "C:\Program Files\Java\" (
    echo ✓ Found Java folder: C:\Program Files\Java\
    dir "C:\Program Files\Java\" /b
    echo.
)

if exist "C:\Program Files (x86)\Java\" (
    echo ✓ Found Java folder: C:\Program Files (x86)\Java\
    dir "C:\Program Files (x86)\Java\" /b
    echo.
)

if exist "C:\Program Files\Eclipse Adoptium\" (
    echo ✓ Found Adoptium Java: C:\Program Files\Eclipse Adoptium\
    dir "C:\Program Files\Eclipse Adoptium\" /b
    echo.
)

if exist "C:\Program Files\Microsoft\" (
    echo Checking Microsoft OpenJDK...
    dir "C:\Program Files\Microsoft\" /b | findstr /i jdk
    echo.
)

echo.
echo ========================================
echo            SOLUTIONS
echo ========================================
echo.

echo SOLUTION 1: Add Java to PATH
echo 1. Press Windows + R
echo 2. Type: sysdm.cpl
echo 3. Click Environment Variables
echo 4. Find PATH in System Variables
echo 5. Add Java bin folder (example: C:\Program Files\Java\jdk-17\bin)
echo.

echo SOLUTION 2: Download Different Java
echo Try Oracle Java instead:
echo https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe
echo.

echo SOLUTION 3: Use Manual Java Path
echo I'll create a script that finds Java automatically
echo.

echo Creating FIXED_BUILD.bat...

REM Create a fixed build script
(
echo @echo off
echo title Fixed Java Build
echo color 0A
echo.
echo echo Finding Java automatically...
echo.
echo REM Try multiple Java locations
echo set JAVA_FOUND=0
echo.
echo if exist "C:\Program Files\Java\jdk*\bin\java.exe" ^(
echo     for /d %%%%i in ^("C:\Program Files\Java\jdk*"^) do ^(
echo         if exist "%%%%i\bin\java.exe" ^(
echo             set "JAVA_HOME=%%%%i"
echo             set JAVA_FOUND=1
echo             goto java_found
echo         ^)
echo     ^)
echo ^)
echo.
echo if exist "C:\Program Files\Eclipse Adoptium\*\bin\java.exe" ^(
echo     for /d %%%%i in ^("C:\Program Files\Eclipse Adoptium\*"^) do ^(
echo         if exist "%%%%i\bin\java.exe" ^(
echo             set "JAVA_HOME=%%%%i"
echo             set JAVA_FOUND=1
echo             goto java_found
echo         ^)
echo     ^)
echo ^)
echo.
echo if exist "C:\Program Files ^(x86^)\Java\*\bin\java.exe" ^(
echo     for /d %%%%i in ^("C:\Program Files ^(x86^)\Java\*"^) do ^(
echo         if exist "%%%%i\bin\java.exe" ^(
echo             set "JAVA_HOME=%%%%i"
echo             set JAVA_FOUND=1
echo             goto java_found
echo         ^)
echo     ^)
echo ^)
echo.
echo if %%%%JAVA_FOUND%%%%==0 ^(
echo     echo ❌ Java not found in any common location
echo     echo Please install Java from: https://adoptium.net/temurin/releases/
echo     pause
echo     exit
echo ^)
echo.
echo :java_found
echo echo ✓ Found Java at: %%%%JAVA_HOME%%%%
echo set "PATH=%%%%JAVA_HOME%%%%\bin;%%%%PATH%%%%"
echo.
echo echo Testing Java...
echo "%%%%JAVA_HOME%%%%\bin\java" -version
echo.
echo echo Building APK...
echo call gradlew.bat clean assembleRelease
echo.
echo if exist "app\build\outputs\apk\release\app-release.apk" ^(
echo     echo ✓ APK built successfully!
echo     explorer "app\build\outputs\apk\release\"
echo ^) else ^(
echo     echo ❌ Build failed
echo ^)
echo pause
) > FIXED_BUILD.bat

echo ✓ Created FIXED_BUILD.bat
echo.
echo Now try running FIXED_BUILD.bat instead!
echo It will find Java automatically.
echo.
pause