# Safe crawler4j Environment Setup - No Global Impact
Write-Host "=== Safe crawler4j Environment Setup ===" -ForegroundColor Green

# Create local Java directory
$localJavaDir = ".\java8"
$java8Path = "$localJavaDir\jdk1.8.0_392"

if (Test-Path $java8Path) {
    Write-Host "Local Java 8 already exists at: $java8Path" -ForegroundColor Green
} else {
    Write-Host "Setting up local Java 8 environment..." -ForegroundColor Cyan
    
    # Create local directory
    New-Item -ItemType Directory -Path $localJavaDir -Force | Out-Null
    
    # Download Java 8 to local directory
    $java8Url = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u392b08.zip"
    $java8Zip = "$localJavaDir\openjdk8.zip"
    
    Write-Host "Downloading Java 8 to local directory..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $java8Url -OutFile $java8Zip -UseBasicParsing
        Write-Host "Download completed!" -ForegroundColor Green
        
        # Extract to local directory
        Write-Host "Extracting Java 8..." -ForegroundColor Yellow
        Expand-Archive -Path $java8Zip -DestinationPath $localJavaDir -Force
        
        # Rename extracted folder
        $extractedFolder = Get-ChildItem $localJavaDir -Directory | Where-Object { $_.Name -like "jdk*" } | Select-Object -First 1
        if ($extractedFolder) {
            Rename-Item $extractedFolder.FullName "jdk1.8.0_392"
        }
        
        # Cleanup zip file
        Remove-Item $java8Zip -Force
        
        Write-Host "Local Java 8 installed to: $java8Path" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download Java 8: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please download manually from: https://adoptium.net/temurin/releases/?version=8" -ForegroundColor Yellow
        exit 1
    }
}

# Set LOCAL environment variables (only for this session)
$env:JAVA_HOME = (Resolve-Path $java8Path).Path
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Local JAVA_HOME set to: $env:JAVA_HOME" -ForegroundColor Green
Write-Host "Note: This only affects the current PowerShell session" -ForegroundColor Yellow

# Create local.properties for Gradle
$localProps = @"
org.gradle.java.home=$env:JAVA_HOME
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
"@

$localProps | Out-File -FilePath "local.properties" -Encoding UTF8
Write-Host "Created local.properties file" -ForegroundColor Green

# Test local Java installation
Write-Host "Testing local Java installation..." -ForegroundColor Cyan
try {
    $javaVersion = & java -version 2>&1
    Write-Host "Java version:" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor White
    
    if ($javaVersion -match "1\.8\.0") {
        Write-Host "✓ Local Java 8 is working correctly!" -ForegroundColor Green
    } else {
        Write-Host "✗ Java 8 not detected" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Java not found in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Local Environment Setup Complete! ===" -ForegroundColor Green
Write-Host "✓ Java 8 is isolated to this project directory" -ForegroundColor Green
Write-Host "✓ Your global Java 23 installation is unaffected" -ForegroundColor Green
Write-Host "✓ Environment only affects this PowerShell session" -ForegroundColor Green
Write-Host "`nYou can now run:" -ForegroundColor Cyan
Write-Host "  ./gradlew build" -ForegroundColor White
Write-Host "  ./gradlew test" -ForegroundColor White
