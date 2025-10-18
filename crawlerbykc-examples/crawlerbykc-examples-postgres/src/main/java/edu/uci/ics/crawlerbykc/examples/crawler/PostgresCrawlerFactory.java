ackage edu.uci.ics.crawlerbykc.examples.crawler;

import com.mchange.v2.c3p0.ComboPooledDataSource;

import edu.uci.ics.crawlerbykc.crawler.CrawlController;
import edu.uci.ics.crawlerbykc.examples.db.impl.PostgresDBServiceImpl;

public class PostgresCrawlerFactory implements CrawlController.WebCrawlerFactory<PostgresWebCrawler> {

    private ComboPooledDataSource comboPooledDataSource;

    public PostgresCrawlerFactory(ComboPooledDataSource comboPooledDataSource) {
        this.comboPooledDataSource = comboPooledDataSource;
    }

    public PostgresWebCrawler newInstance() throws Exception {
        return new PostgresWebCrawler(new PostgresDBServiceImpl(comboPooledDataSource));
    }
}

