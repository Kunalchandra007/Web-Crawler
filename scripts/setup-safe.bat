@echo off
echo === Safe crawler4j Environment Setup ===
echo This will download Java 8 to a local folder only
echo Your global Java 23 installation will NOT be affected
echo.

REM Create local Java directory
if not exist ".\java8" mkdir ".\java8"

REM Check if Java 8 already exists locally
if exist ".\java8\jdk1.8.0_392" (
    echo Local Java 8 already exists
    goto :set_env
)

echo Downloading Java 8 to local directory...
echo This may take a few minutes...

REM Download Java 8 using PowerShell
powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u392b08.zip' -OutFile '.\java8\openjdk8.zip'}"

if not exist ".\java8\openjdk8.zip" (
    echo Download failed. Please download manually from:
    echo https://adoptium.net/temurin/releases/?version=8
    pause
    exit /b 1
)

echo Extracting Java 8...
powershell -Command "& {Expand-Archive -Path '.\java8\openjdk8.zip' -DestinationPath '.\java8' -Force}"

REM Find and rename the extracted folder
for /d %%i in (.\java8\jdk*) do (
    if exist "%%i" (
        if not exist ".\java8\jdk1.8.0_392" (
            move "%%i" ".\java8\jdk1.8.0_392"
        )
    )
)

REM Cleanup zip file
del ".\java8\openjdk8.zip"

:set_env
echo Setting up local environment...

REM Set LOCAL environment variables (only for this session)
set JAVA_HOME=%CD%\java8\jdk1.8.0_392
set PATH=%JAVA_HOME%\bin;%PATH%

echo Local JAVA_HOME set to: %JAVA_HOME%
echo Note: This only affects the current command prompt session

REM Create local.properties for Gradle
echo org.gradle.java.home=%JAVA_HOME% > local.properties
echo org.gradle.daemon=true >> local.properties
echo org.gradle.parallel=true >> local.properties
echo org.gradle.caching=true >> local.properties

echo Created local.properties file

REM Test local Java installation
echo Testing local Java installation...
java -version
if %errorlevel% neq 0 (
    echo Java test failed
    pause
    exit /b 1
)

echo.
echo === Local Environment Setup Complete! ===
echo ✓ Java 8 is isolated to this project directory
echo ✓ Your global Java 23 installation is unaffected
echo ✓ Environment only affects this command prompt session
echo.
echo You can now run:
echo   gradlew build
echo   gradlew test
echo.
pause
