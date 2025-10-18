@echo off
echo === Simple HTTP Crawler Demo ===
echo Using Java 8 environment for compatibility

REM Set up Java 8 environment
set JAVA_HOME=%~dp0temp-files\java8\jdk1.8.0_392
set PATH=%JAVA_HOME%\bin;%PATH%

echo.
echo Using Java 8: %JAVA_HOME%

REM Test Java version
echo.
echo Testing Java version...
java -version
if %errorlevel% neq 0 (
    echo Java not found in PATH
    exit /b 1
)

REM Create temp directory for crawler storage
if not exist "C:\temp\simple-crawler" (
    mkdir "C:\temp\simple-crawler"
    echo Created temp directory: C:\temp\simple-crawler
)

REM Run the Simple HTTP Crawler using Gradle
echo.
echo Starting Simple HTTP Crawler...
echo This will crawl HTTP websites (not HTTPS) to avoid SSL issues
echo    - Uses HTTP websites only
echo    - Respects robots.txt
echo    - Limited to 5 pages for demo
echo    - 1 second delays between requests
echo =====================================

echo.
echo Running crawler with Gradle...
gradlew.bat :crawlerbykc:runSimpleHttpCrawler

echo.
echo =====================================
echo Simple HTTP Crawler completed!
echo Check the output above for crawling results
echo === Demo Complete ===
