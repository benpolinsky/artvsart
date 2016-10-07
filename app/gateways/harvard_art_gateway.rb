# TODO: LIMIT FIELDS BEING RETURNED FROM API
class HarvardArtGateway
  attr_reader :api, :id, :ids, :guaranteed_ids

  def initialize(params={})
    @id = params[:id]
    @ids = params[:ids]
    @guaranteed_ids = ([id]+[ids]).flatten(1).compact
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)} 
  end
  
  def single_listing(listing_id, fields=[])
    # fields + ['title']
    api.get("/object/#{listing_id}?apikey=#{ENV['harvard_token']}").body      
  end
  

  def search(query, query_params={})
    query_params.reverse_merge!({title: query, apikey: ENV['harvard_token']})
    records = api.get("/object?#{query_params.to_param}").body.records
    if records.none?
      {error: "No results found!"}
    elsif !images_present?(records)
      {error: "No images present!"}
    else
      records.select{|r| r['images'].present?}.map{ |record| record['image'] = "#{record['images'].first.baseimageurl}?width=200&height=200"; record}
    end
      
  end
  
  def api(path='http://api.harvardartmuseums.org')
    @api ||= Faraday.new(url: path) do |connection|
      connection.request :url_encoded
      connection.response :json, content_type: /\bjson$/
      connection.adapter Faraday.default_adapter
      connection.use FaradayMiddleware::FollowRedirects
      connection.use Faraday::Response::RaiseError
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
  
  def art_source
    "Harvard Art Gallery"
  end
  

  
  private
  
  def images_present?(records)
    records.map{|r| r['images'] }.present?
  end
  
  
end