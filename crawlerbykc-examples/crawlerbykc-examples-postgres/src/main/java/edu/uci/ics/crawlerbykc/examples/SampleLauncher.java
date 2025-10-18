ackage edu.uci.ics.crawlerbykc.examples;

import org.flywaydb.core.Flyway;

import com.google.common.io.Files;
import com.mchange.v2.c3p0.ComboPooledDataSource;

import edu.uci.ics.crawlerbykc.crawler.CrawlConfig;
import edu.uci.ics.crawlerbykc.crawler.CrawlController;
import edu.uci.ics.crawlerbykc.examples.crawler.PostgresCrawlerFactory;
import edu.uci.ics.crawlerbykc.fetcher.PageFetcher;
import edu.uci.ics.crawlerbykc.robotstxt.RobotstxtConfig;
import edu.uci.ics.crawlerbykc.robotstxt.RobotstxtServer;

public class SampleLauncher {

    public static void main(String[] args) throws Exception {

        String crawlStorageFolder = Files.createTempDir().getAbsolutePath();
        final int numberOfCrawlers = Integer.valueOf(args[2]);

        CrawlConfig config = new CrawlConfig();

        config.setPolitenessDelay(100);

        config.setCrawlStorageFolder(crawlStorageFolder);

        config.setMaxPagesToFetch(Integer.valueOf(args[0]));

        /*
         * Instantiate the controller for this crawl.
         */
        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);

        /*
         * For each crawl, you need to add some seed urls. These are the first
         * URLs that are fetched and then the crawler starts following links
         * which are found in these pages
         */
        controller.addSeed("https://de.wikipedia.org/wiki/Java_Database_Connectivity");
        controller.addSeed("https://de.wikipedia.org/wiki/Relationale_Datenbank");
        controller.addSeed("https://pt.wikipedia.org/wiki/JDBC");
        controller.addSeed("https://pt.wikipedia.org/wiki/Protocolo");
        controller.addSeed("https://de.wikipedia.org/wiki/Datenbank");

        Flyway flyway = new Flyway();
        flyway.setDataSource(args[1], "crawlerbykc", "crawlerbykc");
        flyway.migrate();

        ComboPooledDataSource pool = new ComboPooledDataSource();
        pool.setDriverClass("org.postgresql.Driver");
        pool.setJdbcUrl(args[1]);
        pool.setUser("crawlerbykc");
        pool.setPassword("crawlerbykc");
        pool.setMaxPoolSize(numberOfCrawlers);
        pool.setMinPoolSize(numberOfCrawlers);
        pool.setInitialPoolSize(numberOfCrawlers);

        /*
         * Start the crawl. This is a blocking operation, meaning that your code
         * will reach the line after this only when crawling is finished.
         */
        controller.start(new PostgresCrawlerFactory(pool), numberOfCrawlers);

        pool.close();
    }

}
