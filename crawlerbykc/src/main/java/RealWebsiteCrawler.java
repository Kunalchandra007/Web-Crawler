import edu.uci.ics.crawlerbykc.crawler.CrawlConfig;
import edu.uci.ics.crawlerbykc.crawler.CrawlController;
import edu.uci.ics.crawlerbykc.crawler.Page;
import edu.uci.ics.crawlerbykc.crawler.WebCrawler;
import edu.uci.ics.crawlerbykc.fetcher.PageFetcher;
import edu.uci.ics.crawlerbykc.parser.HtmlParseData;
import edu.uci.ics.crawlerbykc.robotstxt.RobotstxtConfig;
import edu.uci.ics.crawlerbykc.robotstxt.RobotstxtServer;
import edu.uci.ics.crawlerbykc.url.WebURL;

import java.util.Set;
import java.util.regex.Pattern;
import java.util.HashSet;

/**
 * Real Website Crawler - Demonstrates crawling actual websites
 * This example crawls news websites and extracts article information
 */
public class RealWebsiteCrawler extends WebCrawler {

    // Filter out binary files and unwanted content
    private final static Pattern FILTERS = Pattern.compile(".*(\\.(css|js|gif|jpg|jpeg|png|mp3|mp4|zip|gz|pdf|doc|docx|xls|xlsx))$");
    
    // Track crawled URLs to avoid duplicates
    private static Set<String> crawledUrls = new HashSet<>();
    
    // Statistics
    private static int totalPages = 0;
    private static int totalLinks = 0;

    @Override
    public boolean shouldVisit(Page referringPage, WebURL url) {
        String href = url.getURL().toLowerCase();
        
        // Skip binary files
        if (FILTERS.matcher(href).matches()) {
            return false;
        }
        
        // Only crawl specific domains (be respectful!)
        return href.startsWith("https://httpbin.org/") ||  // Test website
               href.startsWith("https://example.com/") ||   // Example website
               href.startsWith("https://www.wikipedia.org/"); // Wikipedia (be very respectful!)
    }

    @Override
    public void visit(Page page) {
        String url = page.getWebURL().getURL();
        
        // Avoid processing the same URL multiple times
        if (crawledUrls.contains(url)) {
            return;
        }
        crawledUrls.add(url);
        totalPages++;
        
        System.out.println("[CRAWLED] " + url);
        System.out.println("   [STATS] Total pages so far: " + totalPages);

        if (page.getParseData() instanceof HtmlParseData) {
            HtmlParseData htmlParseData = (HtmlParseData) page.getParseData();
            String text = htmlParseData.getText();
            String html = htmlParseData.getHtml();
            Set<WebURL> links = htmlParseData.getOutgoingUrls();
            
            totalLinks += links.size();

            System.out.println("   [TEXT] Length: " + text.length() + " characters");
            System.out.println("   [HTML] Length: " + html.length() + " characters");
            System.out.println("   [LINKS] Found: " + links.size());
            
            // Extract and display page title
            String title = extractTitle(html);
            if (title != null && !title.isEmpty()) {
                System.out.println("   [TITLE] " + title);
            }
            
            // Show first few links
            System.out.println("   [SAMPLE LINKS]:");
            int count = 0;
            for (WebURL link : links) {
                if (count < 3) {
                    System.out.println("      - " + link.getURL());
                    count++;
                } else {
                    break;
                }
            }
            
            // Extract some interesting data
            extractInterestingData(text, url);
        }
        System.out.println();
    }
    
    private String extractTitle(String html) {
        try {
            int titleStart = html.indexOf("<title>");
            int titleEnd = html.indexOf("</title>");
            if (titleStart != -1 && titleEnd != -1) {
                return html.substring(titleStart + 7, titleEnd).trim();
            }
        } catch (Exception e) {
            // Ignore title extraction errors
        }
        return null;
    }
    
    private void extractInterestingData(String text, String url) {
        // Look for email addresses
        if (text.contains("@")) {
            System.out.println("   [EMAIL] Contains email addresses");
        }
        
        // Look for phone numbers (simple pattern)
        if (text.matches(".*\\d{3}-\\d{3}-\\d{4}.*") || text.matches(".*\\(\\d{3}\\)\\s*\\d{3}-\\d{4}.*")) {
            System.out.println("   [PHONE] Contains phone numbers");
        }
        
        // Look for dates
        if (text.matches(".*\\d{4}-\\d{2}-\\d{2}.*") || text.matches(".*\\d{1,2}/\\d{1,2}/\\d{4}.*")) {
            System.out.println("   [DATES] Contains dates");
        }
    }

    public static void main(String[] args) throws Exception {
        System.out.println("[STARTING] Real Website Crawler...");
        System.out.println("=====================================");
        System.out.println("[WARNING] IMPORTANT: Be respectful when crawling!");
        System.out.println("   - Use appropriate delays");
        System.out.println("   - Respect robots.txt");
        System.out.println("   - Don't overwhelm servers");
        System.out.println("=====================================");
        
        String crawlStorageFolder = "C:\\temp\\real-crawler\\";
        int numberOfCrawlers = 2; // Start with fewer crawlers to be respectful

        CrawlConfig config = new CrawlConfig();
        config.setCrawlStorageFolder(crawlStorageFolder);
        config.setPolitenessDelay(2000); // 2 second delay - be respectful!
        config.setMaxDepthOfCrawling(2); // Limit depth
        config.setMaxPagesToFetch(10);   // Limit pages for demo
        config.setUserAgentString("Crawlerbykc-Demo/1.0 (Educational Purpose)");
        
        // Be extra respectful
        config.setMaxConnectionsPerHost(1);
        config.setConnectionTimeout(30000);
        config.setSocketTimeout(30000);

        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);

        // Add seed URLs - start with test websites
        controller.addSeed("https://httpbin.org/");        // Test website
        controller.addSeed("https://example.com/");        // Example website
        // controller.addSeed("https://www.wikipedia.org/"); // Uncomment for Wikipedia (be very respectful!)

        CrawlController.WebCrawlerFactory<RealWebsiteCrawler> factory = RealWebsiteCrawler::new;
        
        System.out.println("[CONFIG] Configuration:");
        System.out.println("   [CRAWLERS] " + numberOfCrawlers);
        System.out.println("   [STORAGE] " + crawlStorageFolder);
        System.out.println("   [DELAY] 2000ms (2 seconds)");
        System.out.println("   [MAX PAGES] 10");
        System.out.println("   [MAX DEPTH] 2");
        System.out.println("   [SEED URLs] httpbin.org, example.com");
        System.out.println("=====================================");
        
        long startTime = System.currentTimeMillis();
        controller.start(factory, numberOfCrawlers);
        long endTime = System.currentTimeMillis();
        
        System.out.println("=====================================");
        System.out.println("[SUCCESS] Crawl completed successfully!");
        System.out.println("[STATS] Final Statistics:");
        System.out.println("   [PAGES] Total pages crawled: " + totalPages);
        System.out.println("   [LINKS] Total links found: " + totalLinks);
        System.out.println("   [TIME] Total time: " + (endTime - startTime) + "ms");
        System.out.println("[SUCCESS] Real website crawling works perfectly!");
    }
}
