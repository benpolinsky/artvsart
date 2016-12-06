
class HarvardArtGateway < AbstractGateway

# TODO: LIMIT FIELDS BEING RETURNED FROM API

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
      error_response
    elsif !images_present?(records)
      error_response("Results found, but no images present...")
    else
      records.select{|r| r['images'].present?}.map do |record| 
        record['image'] = "#{record['images'].first.baseimageurl}?width=200&height=200"
        record['name'] = record['title']
        record
      end
    end
  end
  
  def art_image(art)
    art.images.first.baseimageurl
  end
  
  def art_images(art)
    art.images.map(&:baseimageurl)
  end
  
  def art_creator(art)
    art['people'] ? art.people.map(&:name).to_sentence : "N/A"
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
    "Visual Arts"
  end
  
  def art_source_link(art)
    art.url
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
 
end