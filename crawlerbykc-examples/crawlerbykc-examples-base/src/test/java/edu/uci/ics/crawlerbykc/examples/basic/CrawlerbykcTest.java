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

/**
 * Simple test crawler for Crawlerbykc
 * This demonstrates basic crawling functionality
 */
public class CrawlerbykcTest extends WebCrawler {

    private final static Pattern FILTERS = Pattern.compile(".*(\\.(css|js|gif|jpg" +
                                                           "|png|mp3|mp4|zip|gz))$");

    @Override
    public boolean shouldVisit(Page referringPage, WebURL url) {
        String href = url.getURL().toLowerCase();
        return !FILTERS.matcher(href).matches() && href.startsWith("https://www.ics.uci.edu/");
    }

    @Override
    public void visit(Page page) {
        String url = page.getWebURL().getURL();
        System.out.println("[CRAWLED] URL: " + url);

        if (page.getParseData() instanceof HtmlParseData) {
            HtmlParseData htmlParseData = (HtmlParseData) page.getParseData();
            String text = htmlParseData.getText();
            String html = htmlParseData.getHtml();
            Set<WebURL> links = htmlParseData.getOutgoingUrls();

            System.out.println("   [TEXT] Length: " + text.length());
            System.out.println("   [HTML] Length: " + html.length());
            System.out.println("   [LINKS] Count: " + links.size());
            
            // Show first few links
            int count = 0;
            for (WebURL link : links) {
                if (count < 3) {
                    System.out.println("   [LINK] " + link.getURL());
                    count++;
                } else {
                    break;
                }
            }
        }
        System.out.println();
    }

    public static void main(String[] args) throws Exception {
        System.out.println("[START] Crawlerbykc Test...");
        System.out.println("=====================================");
        
        String crawlStorageFolder = "C:\\temp\\crawlerbykc\\";
        int numberOfCrawlers = 3;

        CrawlConfig config = new CrawlConfig();
        config.setCrawlStorageFolder(crawlStorageFolder);
        config.setPolitenessDelay(1000);
        config.setMaxDepthOfCrawling(2);
        config.setMaxPagesToFetch(10); // Limit for testing

        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);

        controller.addSeed("https://www.ics.uci.edu/");

        CrawlController.WebCrawlerFactory<CrawlerbykcTest> factory = CrawlerbykcTest::new;
        
        System.out.println("[INFO] Starting crawl with " + numberOfCrawlers + " crawlers...");
        System.out.println("[INFO] Storage folder: " + crawlStorageFolder);
        System.out.println("[INFO] Seed URL: https://www.ics.uci.edu/");
        System.out.println("[INFO] Politeness delay: 1000ms");
        System.out.println("[INFO] Max pages: 10");
        System.out.println("=====================================");
        
        controller.start(factory, numberOfCrawlers);
        
        System.out.println("[COMPLETE] Crawl finished!");
    }
}
