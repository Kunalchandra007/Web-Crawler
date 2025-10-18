# crawler4j Environment Setup Script
# This script sets up a compatible environment for crawler4j

Write-Host "=== crawler4j Environment Setup ===" -ForegroundColor Green

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Warning: Not running as administrator. Some installations may require admin privileges." -ForegroundColor Yellow
}

# Function to download and install Java 8
function Install-Java8 {
    Write-Host "Installing Java 8..." -ForegroundColor Cyan
    
    # Create Java directory
    $javaDir = "C:\Program Files\Java"
    if (-not (Test-Path $javaDir)) {
        New-Item -ItemType Directory -Path $javaDir -Force
    }
    
    # Download OpenJDK 8 (Adoptium)
    $java8Url = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u392b08.zip"
    $java8Zip = "$env:TEMP\openjdk8.zip"
    $java8ExtractPath = "$env:TEMP\openjdk8"
    
    Write-Host "Downloading OpenJDK 8..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $java8Url -OutFile $java8Zip -UseBasicParsing
        Write-Host "Download completed!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download Java 8. Please download manually from: https://adoptium.net/temurin/releases/?version=8" -ForegroundColor Red
        return $false
    }
    
    # Extract Java 8
    Write-Host "Extracting Java 8..." -ForegroundColor Yellow
    try {
        Expand-Archive -Path $java8Zip -DestinationPath $java8ExtractPath -Force
        $extractedFolder = Get-ChildItem $java8ExtractPath -Directory | Select-Object -First 1
        $java8Path = "$javaDir\jdk1.8.0_392"
        
        if (Test-Path $java8Path) {
            Remove-Item $java8Path -Recurse -Force
        }
        
        Move-Item $extractedFolder.FullName $java8Path
        Write-Host "Java 8 installed to: $java8Path" -ForegroundColor Green
        
        # Cleanup
        Remove-Item $java8Zip -Force
        Remove-Item $java8ExtractPath -Recurse -Force
        
        return $java8Path
    } catch {
        Write-Host "Failed to extract Java 8: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to set up environment variables
function Set-EnvironmentVariables {
    param($JavaPath)
    
    Write-Host "Setting up environment variables..." -ForegroundColor Cyan
    
    # Set JAVA_HOME for current session
    $env:JAVA_HOME = $JavaPath
    $env:PATH = "$JavaPath\bin;$env:PATH"
    
    # Set JAVA_HOME permanently
    try {
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaPath, "User")
        Write-Host "JAVA_HOME set to: $JavaPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to set JAVA_HOME permanently: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Update PATH permanently
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$JavaPath\bin*") {
            $newPath = "$JavaPath\bin;$currentPath"
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-Host "PATH updated with Java 8" -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to update PATH permanently: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to verify Java installation
function Test-JavaInstallation {
    Write-Host "Verifying Java installation..." -ForegroundColor Cyan
    
    try {
        $javaVersion = & java -version 2>&1
        Write-Host "Java version:" -ForegroundColor Green
        Write-Host $javaVersion -ForegroundColor White
        
        if ($javaVersion -match "1\.8\.0") {
            Write-Host "✓ Java 8 is working correctly!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Java 8 not detected. Current version may be incompatible." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "✗ Java not found in PATH" -ForegroundColor Red
        return $false
    }
}

# Function to create a local.properties file for Gradle
function Create-LocalProperties {
    Write-Host "Creating local.properties for Gradle..." -ForegroundColor Cyan
    
    $localProps = @"
# Local properties for crawler4j
org.gradle.java.home=$env:JAVA_HOME
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
"@
    
    $localProps | Out-File -FilePath "local.properties" -Encoding UTF8
    Write-Host "Created local.properties file" -ForegroundColor Green
}

# Function to test Gradle build
function Test-GradleBuild {
    Write-Host "Testing Gradle build..." -ForegroundColor Cyan
    
    try {
        Write-Host "Running: ./gradlew --version" -ForegroundColor Yellow
        & ./gradlew --version
        
        Write-Host "Running: ./gradlew build" -ForegroundColor Yellow
        & ./gradlew build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Gradle build successful!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Gradle build failed" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "✗ Gradle build failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Starting environment setup..." -ForegroundColor Green

# Check if Java 8 is already installed
$java8Path = "C:\Program Files\Java\jdk1.8.0_392"
if (Test-Path $java8Path) {
    Write-Host "Java 8 already installed at: $java8Path" -ForegroundColor Green
    Set-EnvironmentVariables -JavaPath $java8Path
} else {
    Write-Host "Java 8 not found. Installing..." -ForegroundColor Yellow
    $java8Path = Install-Java8
    if ($java8Path) {
        Set-EnvironmentVariables -JavaPath $java8Path
    } else {
        Write-Host "Failed to install Java 8. Please install manually." -ForegroundColor Red
        exit 1
    }
}

# Verify installation
if (Test-JavaInstallation) {
    Create-LocalProperties
    
    Write-Host "`n=== Testing crawler4j build ===" -ForegroundColor Green
    if (Test-GradleBuild) {
        Write-Host "`n✓ Environment setup completed successfully!" -ForegroundColor Green
        Write-Host "You can now run crawler4j examples with:" -ForegroundColor Cyan
        Write-Host "  ./gradlew test" -ForegroundColor White
        Write-Host "  ./gradlew :crawler4j-examples:crawler4j-examples-base:test --tests '*BasicCrawlController*'" -ForegroundColor White
    } else {
        Write-Host "`n✗ Build test failed. Please check the errors above." -ForegroundColor Red
    }
} else {
    Write-Host "`n✗ Java installation verification failed." -ForegroundColor Red
    Write-Host "Please restart your terminal and try again." -ForegroundColor Yellow
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
