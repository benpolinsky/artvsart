class ArtsySearcher
  attr_accessor :query, :offset, :number_of_records_per, :api, :params, :errors, :current_results
  
  def initialize(args)
    @query = args[:query]
    @number_of_records_per = args[:number_of_records_per]
    @offset = args[:offset]
    @api = args[:api]
    @params = args[:params]
  end
  
  def find_results
    increase_offset while results? && valid_results?
  end
  
  # maybe #results should store in an
  # instance variable and then
  # #calculate_results will nil that
  # and recalculate 
  # (so you aren't constantly querying)
  def results
    @current_results ||= api.search({
      q: "#{query}+more:pagemap:metatags-og_type:artwork", 
      size: number_of_records_per, 
      offset: offset,
      total_count: 1,
    }.reverse_merge(params))
  end
  
  
  def valid_results?
    valid_results.any?
  end
  
  def results?
    total_count > 0
  end

  
  def last_result?
    total_count <= offset+number_of_records_per
  end
  
  # Like a billion other things with Artsy's API, this is inconsistent.  
  # Again, other APIs don't have this problem, yet it 
  # seems to be beyond Arty's capabilities...
  def total_count
    results.total_count
  end
  
  def increase_offset
    @current_results = results.next
  end
  

  
  private 
  
  def valid_results
    results.results.map do |result|
     begin
       if valid_result?(result.self)
         result.self
       else
         next
       end
     rescue Faraday::ResourceNotFound => e
       # @errors = true
       nil
     end
   end.compact
  end
  
  def valid_result?(result)
    result.id.present? && image_present?(result)
  end
  
  def image_present?(art, image_version='medium')
    "#{art.image._url.split(".jpg")[0]}#{image_version}.jpg"
  end
end