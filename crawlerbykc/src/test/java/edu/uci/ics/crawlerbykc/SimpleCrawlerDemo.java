package edu.uci.ics.crawlerbykc;

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
 * Simple demonstration of Crawlerbykc functionality
 */
public class SimpleCrawlerDemo extends WebCrawler {

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
        System.out.println("✅ Crawled: " + url);

        if (page.getParseData() instanceof HtmlParseData) {
            HtmlParseData htmlParseData = (HtmlParseData) page.getParseData();
            String text = htmlParseData.getText();
            String html = htmlParseData.getHtml();
            Set<WebURL> links = htmlParseData.getOutgoingUrls();

            System.out.println("   📄 Text length: " + text.length());
            System.out.println("   🏷️  HTML length: " + html.length());
            System.out.println("   🔗 Links found: " + links.size());
            
            // Show first few links
            int count = 0;
            for (WebURL link : links) {
                if (count < 2) {
                    System.out.println("   🔗 Link: " + link.getURL());
                    count++;
                } else {
                    break;
                }
            }
        }
        System.out.println();
    }

    public static void main(String[] args) throws Exception {
        System.out.println("🚀 Starting Crawlerbykc Demo...");
        System.out.println("=====================================");
        
        String crawlStorageFolder = "C:\\temp\\crawlerbykc\\";
        int numberOfCrawlers = 2;

        CrawlConfig config = new CrawlConfig();
        config.setCrawlStorageFolder(crawlStorageFolder);
        config.setPolitenessDelay(1000);
        config.setMaxDepthOfCrawling(1);
        config.setMaxPagesToFetch(3); // Limit for demo

        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);

        controller.addSeed("https://www.ics.uci.edu/");

        CrawlController.WebCrawlerFactory<SimpleCrawlerDemo> factory = SimpleCrawlerDemo::new;
        
        System.out.println("⚙️  Configuration:");
        System.out.println("   🧵 Crawlers: " + numberOfCrawlers);
        System.out.println("   📁 Storage: " + crawlStorageFolder);
        System.out.println("   🌐 Seed URL: https://www.ics.uci.edu/");
        System.out.println("   📊 Max pages: 3");
        System.out.println("   📏 Max depth: 1");
        System.out.println("=====================================");
        
        controller.start(factory, numberOfCrawlers);
        
        System.out.println("=====================================");
        System.out.println("✅ Crawl completed successfully!");
        System.out.println("🎉 Crawlerbykc is working perfectly!");
    }
}
