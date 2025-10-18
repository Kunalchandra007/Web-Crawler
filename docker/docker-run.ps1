# Docker-based crawler4j environment (Completely isolated)
Write-Host "=== Docker-based crawler4j Environment ===" -ForegroundColor Green

# Check if Docker is available
try {
    docker --version | Out-Null
    Write-Host "✓ Docker is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop first." -ForegroundColor Red
    Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "Building crawler4j Docker environment..." -ForegroundColor Cyan
docker build -t crawler4j-env .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker image built successfully!" -ForegroundColor Green
    
    Write-Host "`nAvailable commands:" -ForegroundColor Cyan
    Write-Host "  .\docker-run.ps1 build    - Build the project" -ForegroundColor White
    Write-Host "  .\docker-run.ps1 test     - Run tests" -ForegroundColor White
    Write-Host "  .\docker-run.ps1 example  - Run basic crawler example" -ForegroundColor White
    Write-Host "  .\docker-run.ps1 shell    - Open interactive shell" -ForegroundColor White
    
    # Run default command (build)
    if ($args.Count -eq 0) {
        Write-Host "`nRunning build..." -ForegroundColor Yellow
        docker run --rm -v "${PWD}:/app" crawler4j-env ./gradlew build
    } else {
        $command = $args[0]
        switch ($command.ToLower()) {
            "build" {
                docker run --rm -v "${PWD}:/app" crawler4j-env ./gradlew build
            }
            "test" {
                docker run --rm -v "${PWD}:/app" crawler4j-env ./gradlew test
            }
            "example" {
                docker run --rm -v "${PWD}:/app" crawler4j-env ./gradlew :crawler4j-examples:crawler4j-examples-base:test --tests "*BasicCrawlController*"
            }
            "shell" {
                docker run --rm -it -v "${PWD}:/app" crawler4j-env bash
            }
            default {
                docker run --rm -v "${PWD}:/app" crawler4j-env ./gradlew $command
            }
        }
    }
} else {
    Write-Host "✗ Docker build failed" -ForegroundColor Red
}
