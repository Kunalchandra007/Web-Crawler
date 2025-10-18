# PowerShell script to run the real website crawler
Write-Host "=== Real Website Crawler Demo ===" -ForegroundColor Green
Write-Host "This will crawl real websites - be respectful!" -ForegroundColor Yellow

# Compile the crawler
Write-Host "`nCompiling RealWebsiteCrawler..." -ForegroundColor Cyan
temp-files\java8\jdk1.8.0_392\bin\javac.exe -cp "crawlerbykc\build\classes\java\main" RealWebsiteCrawler.java

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful!" -ForegroundColor Green
    
    # Create temp directory
    if (!(Test-Path "C:\temp\real-crawler")) {
        New-Item -ItemType Directory -Path "C:\temp\real-crawler" -Force
        Write-Host "Created temp directory: C:\temp\real-crawler" -ForegroundColor Yellow
    }
    
    Write-Host "`nStarting real website crawler..." -ForegroundColor Cyan
    Write-Host "This will crawl real websites with respectful delays" -ForegroundColor Yellow
    Write-Host "   - 2 second delays between requests" -ForegroundColor White
    Write-Host "   - Respects robots.txt" -ForegroundColor White
    Write-Host "   - Limited to 10 pages for demo" -ForegroundColor White
    Write-Host "   - Only crawls test websites" -ForegroundColor White
    
    # Run the crawler
    temp-files\java8\jdk1.8.0_392\bin\java.exe -cp "crawlerbykc\build\classes\java\main;." RealWebsiteCrawler
    
    Write-Host "`nReal website crawling completed!" -ForegroundColor Green
    Write-Host "Check the output above for crawling results" -ForegroundColor Cyan
} else {
    Write-Host "Compilation failed!" -ForegroundColor Red
}

Write-Host "`n=== Demo Complete ===" -ForegroundColor Green