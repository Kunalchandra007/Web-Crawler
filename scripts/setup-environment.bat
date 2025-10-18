@echo off
echo === crawler4j Environment Setup ===

REM Check if Java 8 is already installed
set JAVA8_PATH=C:\Program Files\Java\jdk1.8.0_392
if exist "%JAVA8_PATH%" (
    echo Java 8 already installed at: %JAVA8_PATH%
    goto :set_env
)

echo Java 8 not found. Please install Java 8 manually.
echo.
echo Download from: https://adoptium.net/temurin/releases/?version=8
echo Or use the PowerShell script: setup-environment.ps1
echo.
pause
exit /b 1

:set_env
echo Setting up environment variables...

REM Set JAVA_HOME for current session
set JAVA_HOME=%JAVA8_PATH%
set PATH=%JAVA8_PATH%\bin;%PATH%

REM Set JAVA_HOME permanently
setx JAVA_HOME "%JAVA8_PATH%" /M
setx PATH "%JAVA8_PATH%\bin;%PATH%" /M

echo JAVA_HOME set to: %JAVA_HOME%

REM Create local.properties for Gradle
echo Creating local.properties...
echo org.gradle.java.home=%JAVA_HOME% > local.properties
echo org.gradle.daemon=true >> local.properties
echo org.gradle.parallel=true >> local.properties
echo org.gradle.caching=true >> local.properties

echo.
echo Testing Java installation...
java -version
if %errorlevel% neq 0 (
    echo Java not found in PATH. Please restart your terminal.
    pause
    exit /b 1
)

echo.
echo Testing Gradle build...
gradlew --version
if %errorlevel% neq 0 (
    echo Gradle test failed.
    pause
    exit /b 1
)

echo.
echo Running build test...
gradlew build
if %errorlevel% neq 0 (
    echo Build failed. Check the errors above.
    pause
    exit /b 1
)

echo.
echo === Environment setup completed successfully! ===
echo You can now run crawler4j examples with:
echo   gradlew test
echo   gradlew :crawler4j-examples:crawler4j-examples-base:test --tests "*BasicCrawlController*"
echo.
pause
