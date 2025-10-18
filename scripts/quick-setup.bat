@echo off
echo === Quick crawler4j Setup (No Global Impact) ===

REM Check if we have Docker
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Docker found! Using Docker approach (completely isolated)
    echo.
    echo Building Docker environment...
    docker build -t crawler4j-env .
    if %errorlevel% equ 0 (
        echo.
        echo ✓ Docker environment ready!
        echo.
        echo Available commands:
        echo   quick-setup.bat build    - Build the project
        echo   quick-setup.bat test     - Run tests  
        echo   quick-setup.bat example  - Run basic crawler example
        echo.
        if "%1"=="build" (
            docker run --rm -v "%CD%:/app" crawler4j-env ./gradlew build
        ) else if "%1"=="test" (
            docker run --rm -v "%CD%:/app" crawler4j-env ./gradlew test
        ) else if "%1"=="example" (
            docker run --rm -v "%CD%:/app" crawler4j-env ./gradlew :crawler4j-examples:crawler4j-examples-base:test --tests "*BasicCrawlController*"
        ) else (
            docker run --rm -v "%CD%:/app" crawler4j-env ./gradlew build
        )
    ) else (
        echo Docker build failed
    )
) else (
    echo Docker not found. Please install Docker Desktop or use PowerShell scripts.
    echo.
    echo Alternative approaches:
    echo 1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
    echo 2. Use PowerShell: .\setup-local-env.ps1
    echo 3. Use manual Java 8 installation (affects global environment)
)

pause
