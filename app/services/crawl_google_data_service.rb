require 'resolv-replace'

class CrawlGoogleDataService
  def initialize(result_id:)
    @result_id = result_id
  end

  def call
    Result.transaction do
      @data = fetch_search_result

      ads = parse_ads
      links = parse_links
      total_results = parse_totol_result

      result.done!
      result.update!(total_ads: ads.size, total_links: links.size, total_results: total_results)
      result.create_source_code!(content: data)
    end
  end

  private

  attr_reader :result_id, :data

  def result
    @result ||= Result.find(result_id)
  end

  def keyword
    @keyword ||= result.keyword
  end

  def fetch_search_result
    url = GOOGLE_SEARCH_URI + URI.encode_www_form_component(keyword)
    uri = URI.parse(url)
    req_options = { use_ssl: uri.scheme == 'https' }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      request = Net::HTTP::Get.new(uri)
      request['Authority'] = HEADER_AUTHORITY
      request['User-Agent'] = HEADER_AGENT

      http.request(request)
    end

    Nokogiri::HTML(response.body)
  end

  def parse_ads
    data.css("#{ADS_ID} > div")
  end

  def parse_links
    data.css('a > @href').uniq
  end

  def parse_totol_result
    data.css(TOTAL_RESULTS_ID).text
  end
end
