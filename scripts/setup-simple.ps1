# Simple crawler4j Environment Setup Script
Write-Host "=== crawler4j Environment Setup ===" -ForegroundColor Green

# Check if Java 8 is already installed
$java8Path = "C:\Program Files\Java\jdk1.8.0_392"
if (Test-Path $java8Path) {
    Write-Host "Java 8 already installed at: $java8Path" -ForegroundColor Green
} else {
    Write-Host "Java 8 not found. Please install Java 8 manually." -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/temurin/releases/?version=8" -ForegroundColor Yellow
    Write-Host "Or run: winget install EclipseAdoptium.Temurin.8.JDK" -ForegroundColor Yellow
    exit 1
}

# Set environment variables for current session
$env:JAVA_HOME = $java8Path
$env:PATH = "$java8Path\bin;$env:PATH"

Write-Host "JAVA_HOME set to: $env:JAVA_HOME" -ForegroundColor Green

# Create local.properties for Gradle
$localProps = @"
org.gradle.java.home=$java8Path
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
"@

$localProps | Out-File -FilePath "local.properties" -Encoding UTF8
Write-Host "Created local.properties file" -ForegroundColor Green

# Test Java installation
Write-Host "Testing Java installation..." -ForegroundColor Cyan
try {
    $javaVersion = & java -version 2>&1
    Write-Host "Java version:" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor White
    
    if ($javaVersion -match "1\.8\.0") {
        Write-Host "✓ Java 8 is working correctly!" -ForegroundColor Green
    } else {
        Write-Host "✗ Java 8 not detected" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Java not found in PATH" -ForegroundColor Red
    exit 1
}

# Test Gradle
Write-Host "Testing Gradle..." -ForegroundColor Cyan
try {
    & ./gradlew --version
    Write-Host "✓ Gradle is working!" -ForegroundColor Green
} catch {
    Write-Host "✗ Gradle test failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Environment setup completed! ===" -ForegroundColor Green
Write-Host "You can now run:" -ForegroundColor Cyan
Write-Host "  ./gradlew build" -ForegroundColor White
Write-Host "  ./gradlew test" -ForegroundColor White
