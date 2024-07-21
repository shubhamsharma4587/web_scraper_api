class Api::V1::CompaniesController < ApplicationController
  def index
    n = params[:n].to_i
    filters = company_filters

    scraper = YCScraperService.new(n, filters)
    companies = scraper.scrape_companies

    send_data generate_csv(companies), filename: "yc_companies.csv"
  end

  private

  def company_filters
    params.require(:filters).permit(:batch, :industry, :regions, :tags, :team_size, :isHiring, :nonprofit, :highlight_black, :hispanic_latino_founded, :highlight_women).to_h
  end

  def generate_csv(companies)
    CSV.generate(headers: true) do |csv|
      csv << ['Name', 'Location', 'Short Description', 'YC Batch', 'Website', 'Founders', 'LinkedIn URLs']
      companies.each do |company|
        csv << [
          company[:name],
          company[:location],
          company[:short_description],
          company[:yc_batch],
          company[:website],
          company[:founders].join(', '),
          company[:linkedin_urls].join(', ')
        ]
      end if companies.present?
    end
  end
end
