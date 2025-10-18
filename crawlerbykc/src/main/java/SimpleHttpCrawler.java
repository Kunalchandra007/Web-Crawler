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
 * Simple HTTP Crawler - Works with Java 8 and older SSL/TLS
 * This example crawls HTTP websites (not HTTPS) to avoid SSL issues
 */
public class SimpleHttpCrawler extends WebCrawler {

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
        
        // Only crawl HTTP websites (not HTTPS) to avoid SSL issues
        return href.startsWith("http://") && 
               (href.contains("httpbin.org") || 
                href.contains("example.com") ||
                href.contains("httpbin.org"));
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
        System.out.println("[STARTING] Simple HTTP Crawler...");
        System.out.println("=====================================");
        System.out.println("[INFO] This crawler uses HTTP (not HTTPS) to avoid SSL issues");
        System.out.println("   - Uses HTTP websites only");
        System.out.println("   - Respects robots.txt");
        System.out.println("   - Limited to 5 pages for demo");
        System.out.println("=====================================");
        
        String crawlStorageFolder = "C:\\temp\\simple-crawler\\";
        int numberOfCrawlers = 1; // Single crawler for simplicity

        CrawlConfig config = new CrawlConfig();
        config.setCrawlStorageFolder(crawlStorageFolder);
        config.setPolitenessDelay(1000); // 1 second delay
        config.setMaxDepthOfCrawling(1); // Limit depth
        config.setMaxPagesToFetch(5);    // Limit pages for demo
        config.setUserAgentString("SimpleHttpCrawler/1.0 (Educational Purpose)");
        
        // Simple configuration
        config.setMaxConnectionsPerHost(1);
        config.setConnectionTimeout(10000);
        config.setSocketTimeout(10000);

        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);

        // Add seed URLs - HTTP only to avoid SSL issues
        controller.addSeed("http://httpbin.org/");        // Test website
        controller.addSeed("http://example.com/");        // Example website

        CrawlController.WebCrawlerFactory<SimpleHttpCrawler> factory = SimpleHttpCrawler::new;
        
        System.out.println("[CONFIG] Configuration:");
        System.out.println("   [CRAWLERS] " + numberOfCrawlers);
        System.out.println("   [STORAGE] " + crawlStorageFolder);
        System.out.println("   [DELAY] 1000ms (1 second)");
        System.out.println("   [MAX PAGES] 5");
        System.out.println("   [MAX DEPTH] 1");
        System.out.println("   [SEED URLs] httpbin.org, example.com (HTTP only)");
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
        System.out.println("[SUCCESS] Crawling complete!");
    }
}
