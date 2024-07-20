require 'selenium-webdriver'
require 'csv'
require 'webdrivers'

class YCScraperService
  BASE_URL = 'https://www.ycombinator.com/companies'

  def initialize(n, filters)
    @n = n
    @filters = filters
    options = Selenium::WebDriver::Chrome::Options.new
    @driver = Selenium::WebDriver.for :chrome, options: options
  end

  def scrape_companies
    companies = []
    page = 1

    while companies.size < @n
      url = build_url(page)
      @driver.get(url)
      wait_for_element('//a[contains(@class, "_company_")]')
      company_cards = @driver.find_elements(xpath: '//a[contains(@class, "_company_")]')
      company_cards.each do |company_card|
        company = parse_company_card(company_card)
        company_details = fetch_company_details(company[:details_url], company[:name])
        companies << company.merge(company_details)

        break if companies.size >= @n
      end

      page += 1
    end

    @driver.quit
    companies
  end

  private


  def build_url(page)
    filters_query = @filters.empty? ? "" : @filters.map do |key, value|
      if key == 'team_size'
        encoded_team_size = URI.encode_www_form_component([value.split("-")].to_json)
        "#{key}=#{encoded_team_size}"
      else
        "#{key}=#{URI.encode_www_form_component(value)}"
      end
    end.join('&')
    "#{BASE_URL}?page=#{page}&#{filters_query}"
  end

  def parse_company_card(card)
    {
        name: card.find_element(xpath: '//span[contains(@class, "_coName_")]').text.strip,
        location: card.find_element(xpath: '//span[contains(@class, "_coLocation_")]').text.strip,
        short_description: card.find_element(xpath: '//span[contains(@class, "_coDescription_")]').text.strip,
        yc_batch: card.find_element(xpath: '//a[contains(@href, "/companies?batch=")]//span').text.strip,
        details_url: card.find_element(xpath: '//a[contains(@class, "_company_")]')['href']
    }
  end

  def fetch_company_details(url,name)
    @driver.get(url)
    wait_for_element("//h1[contains(text(), '#{name}')]")

    {
        website: @driver.find_element(xpath: '//div[contains(@class,"inline-block group-hover:underline")]').text.strip,
        founders: @driver.find_elements(xpath: '//h3[text() = "Active Founders"]//../following-sibling::div//div[@class="font-bold"]').map(&:text).map(&:strip),
        linkedin_urls: @driver.find_elements(xpath: '//h3[text() = "Active Founders"]//../following-sibling::div//a[contains(@class, "bg-image-linkedin")]').map { |link| link['href'] }
    }
  end

  def wait_for_element(xpath, timeout = 10)
    begin
      Selenium::WebDriver::Wait.new(timeout: timeout).until { @driver.find_element(xpath: xpath) }
    rescue Exception => ex
      puts "Exception: #{ex.to_s}"
      @driver.quit
    end
  end
end
