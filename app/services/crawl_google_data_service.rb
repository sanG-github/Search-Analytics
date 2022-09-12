class CrawlGoogleDataService
  def initialize(keyword:)
    @keyword = keyword
  end

  def call
    doc = fetch_search_result

    ads = doc.css("#{ADS_ID} > div")
    total_ads = ads.size

    links = doc.css('a > @href').uniq
    total_links = links.size

    total_results = doc.css(TOTAL_RESULTS_ID).text

    [total_links, total_results, total_ads]
  end

  private

  attr_reader :keyword

  def fetch_search_result
    url = GOOGLE_SEARCH_URI + keyword
    uri = URI.parse(CGI.escape(url))
    req_options = { use_ssl: uri.scheme == 'https' }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      request = Net::HTTP::Get.new(uri)
      request['Authority'] = HEADER_AUTHORITY
      request['User-Agent'] = HEADER_AGENT

      http.request(request)
    end

    Nokogiri::HTML(response.body)
  end
end
