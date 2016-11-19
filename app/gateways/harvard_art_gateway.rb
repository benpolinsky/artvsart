# TODO: LIMIT FIELDS BEING RETURNED FROM API
# TODO: Change id/ids to listing_id/listing_ids

class HarvardArtGateway
  attr_reader :api, :listing_id, :listing_ids, :guaranteed_ids, :errors

  def initialize(params={})
    @listing_id = params[:listing_id]
    @listing_ids = params[:listing_ids]
    @guaranteed_ids = ([listing_id]+[listing_ids]).flatten(1).compact
    @errors = []
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)} 
  end
  
  def single_listing(listing_id, fields=[])
    # fields + ['title']
    response = api.get("/object/#{listing_id}?apikey=#{ENV['harvard_token']}")   
    if response.body['error']
      error_response(response.body['error'])
    else
      response.body
    end
  end
  

  def search(query, query_params={})
    query_params.reverse_merge!({q: query, apikey: ENV['harvard_token']})
    records = api.get("/object?#{query_params.to_param}").body.records
    if records.none?
      @errors << "No results found!"
      false
    elsif !images_present?(records)
      @errors << "Results found, but no images present..."
      false
    else
      records.select{|r| r['images'].present?}.map{ |record| record['image'] = "#{record['images'].first.baseimageurl}?width=200&height=200"; record}
    end
  end
  
  def art_image(art)
    art.images.first.baseimageurl
  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art)]
  end
  
  def art_images(art)
    art.images.map(&:baseimageurl)
  end
  
  def art_name(art)
    art.title
  end
  
  def art_creator(art)
    art.people.map(&:name).to_sentence
  end
  
  def art_description(art)
    description = ""
    description += "Technique: #{art.technique}\n" if art.technique
    description += "#{art.description}"
  end
  
  def art_release_date(art)
    art.dated
  end

  def art_category(art)
    "Art"
  end
  
  def art_source
    "Harvard Art Gallery"
  end
  
  def art_source_link(art)
    art.url
  end
  
  def valid?
    !items.any?{|item| item == false} 
  end
  
  private
  
  def api(path='http://api.harvardartmuseums.org')
    @api ||= Faraday.new(url: path) do |connection|
      connection.request :url_encoded
      connection.response :json, content_type: /\bjson$/
      connection.adapter Faraday.default_adapter
      connection.use FaradayMiddleware::FollowRedirects
      connection.use Faraday::Response::RaiseError
    end
  end
  
  def images_present?(records)
    records.map{|r| r['images'] }.present?
  end
  
  def error_response(message="No Results Found!")
    @errors << message
    false 
  end
end