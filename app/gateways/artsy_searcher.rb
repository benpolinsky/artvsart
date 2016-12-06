class ArtsySearcher
  # Lord, I'd increase this if I could...
  NUMBER_OF_RECORDS_PER = 10
  
  attr_accessor :query, 
                :api, 
                :params, 
                :errors, 
                :current_results
  
  def initialize(args)
    @query = args[:query]
    @api = args[:api]
    @params = args[:params]
  end
  
  def find_results
    next_results while results? && !valid_results?
  end

  def results

    @current_results ||= api.search({
      q: "#{query}+more:pagemap:metatags-og_type:artwork", 
      size: NUMBER_OF_RECORDS_PER, 
      total_count: 1,
    }.reverse_merge(params))
  end
  
  def results?
    total_count > 0
  end
  

  
  private 
  
  def valid_results?
    valid_results.any?
  end
  
  def valid_results
    @current_results = results.results.map do |result|
      begin
        valid_result?(result.self) ? result : nil
      rescue Faraday::ResourceNotFound => e
        nil
      end
    end.compact
  end
  
  def valid_result?(result)
    result.self.id.present? && image_present?(result)
  end
  
  def image_present?(art, image_version='medium')
    "#{art.self['image']._url.split(".jpg")[0]}#{image_version}.jpg"
  end
  
  def total_count
    results.total_count
  end
  
  def next_results
    @current_results = results.next
  end
end