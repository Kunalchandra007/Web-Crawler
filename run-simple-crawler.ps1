# PowerShell script to run the Simple HTTP Crawler with Java 8
Write-Host "=== Simple HTTP Crawler Demo ===" -ForegroundColor Green
Write-Host "Using Java 8 environment for compatibility" -ForegroundColor Yellow

# Set up Java 8 environment
$java8Path = "temp-files\java8\jdk1.8.0_392"
$env:JAVA_HOME = (Resolve-Path $java8Path).Path
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Using Java 8: $env:JAVA_HOME" -ForegroundColor Cyan

# Test Java version
Write-Host "Testing Java version..." -ForegroundColor Cyan
$javaVersion = & java -version 2>&1
Write-Host "Java version:" -ForegroundColor Green
Write-Host $javaVersion -ForegroundColor White

if ($javaVersion -match "1\.8\.0") {
    Write-Host "Java 8 is working correctly!" -ForegroundColor Green
} else {
    Write-Host "Java 8 not detected" -ForegroundColor Red
    exit 1
}

# Create temp directory for crawler storage
$tempDir = "C:\temp\simple-crawler"
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "Created temp directory: $tempDir" -ForegroundColor Yellow
}

# Run the Simple HTTP Crawler
Write-Host "Starting Simple HTTP Crawler..." -ForegroundColor Cyan
Write-Host "This will crawl HTTP websites (not HTTPS) to avoid SSL issues" -ForegroundColor Yellow
Write-Host "   - Uses HTTP websites only" -ForegroundColor White
Write-Host "   - Respects robots.txt" -ForegroundColor White
Write-Host "   - Limited to 5 pages for demo" -ForegroundColor White
Write-Host "   - 1 second delays between requests" -ForegroundColor White
Write-Host "=====================================" -ForegroundColor Green

# Run the crawler with proper classpath including all dependencies
Write-Host "Running crawler..." -ForegroundColor Yellow

# Try to run with Gradle first (handles dependencies automatically)
Write-Host "Attempting to run with Gradle..." -ForegroundColor Cyan
try {
    & .\gradlew.bat :crawlerbykc:runSimpleHttpCrawler
} catch {
    Write-Host "Gradle approach failed, trying direct Java execution..." -ForegroundColor Yellow
    
    # Try direct Java execution with all available JARs
    $classpath = "crawlerbykc\build\classes\java\main;crawlerbykc\build\libs\*;."
    Write-Host "Using classpath: $classpath" -ForegroundColor Cyan
    & java -cp $classpath SimpleHttpCrawler
}

Write-Host "Crawling Completed" -ForegroundColor Green