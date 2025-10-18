ackage edu.uci.ics.crawlerbykc.examples.db;

import edu.uci.ics.crawlerbykc.crawler.Page;

public interface PostgresDBService {

    void store(Page webPage);

    void close();
}
