# Run crawler4j with local Java 8 environment
# This script sets up the local environment and runs commands

param(
    [string]$Command = "build"
)

Write-Host "=== Running crawler4j with local Java 8 ===" -ForegroundColor Green

# Set up local Java 8 environment
$localJavaDir = ".\java8"
$java8Path = "$localJavaDir\jdk1.8.0_392"

if (-not (Test-Path $java8Path)) {
    Write-Host "Local Java 8 not found. Please run setup-local-env.ps1 first." -ForegroundColor Red
    exit 1
}

# Set local environment variables
$env:JAVA_HOME = (Resolve-Path $java8Path).Path
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Using local Java 8: $env:JAVA_HOME" -ForegroundColor Cyan

# Run the specified command
switch ($Command.ToLower()) {
    "build" {
        Write-Host "Running: ./gradlew build" -ForegroundColor Yellow
        & ./gradlew build
    }
    "test" {
        Write-Host "Running: ./gradlew test" -ForegroundColor Yellow
        & ./gradlew test
    }
    "example" {
        Write-Host "Running basic crawler example..." -ForegroundColor Yellow
        & ./gradlew :crawler4j-examples:crawler4j-examples-base:test --tests "*BasicCrawlController*"
    }
    "clean" {
        Write-Host "Running: ./gradlew clean" -ForegroundColor Yellow
        & ./gradlew clean
    }
    default {
        Write-Host "Running: ./gradlew $Command" -ForegroundColor Yellow
        & ./gradlew $Command
    }
}

Write-Host "`nCommand completed!" -ForegroundColor Green
