package edu.uci.ics.crawlerbykc.parser;

import edu.uci.ics.crawlerbykc.crawler.Page;
import edu.uci.ics.crawlerbykc.crawler.exceptions.ParseException;

public interface HtmlParser {

    HtmlParseData parse(Page page, String contextURL) throws ParseException;

}

