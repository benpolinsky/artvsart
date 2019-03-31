require 'http'
require 'net/http'
require 'json'

class ArtsyGateway
  ARTSY_ENDPOINT = 'https://api.artsy.net/api'
  ARTWORK_ENDPOINT = 'https://api.artsy.net/api/artworks'
  SEARCH_ENDPOINT = 'https://api.artsy.net/api/search'
  
  attr_accessor :listing_id, :listing_ids, :api, :errors
  
  def initialize(params={})
    @listing_id  = params[:listing_id]
    @listing_ids = params[:listing_ids]
    @errors = []
    renew_token if !token || token.expiring_soon?
  end
  
  def items
    guaranteed_items.map{|listing_id| single_listing(listing_id) }
  end

  #  this is getting crazy..
  # 1. we're using error handling as a conditional
  # 2. two nested conditionals
  # 3. will have to duplicate the behavior for single_listing as well...
  # and most of it is because artsy doesn't provide a way to query what we need...
  def search(query, params={})
    number_of_records_per = 10
    offset = params[:offset] ? params[:offset] : 0
    
      # begin
      
      response = api.get(SEARCH_ENDPOINT, params: {q: query, type: 'artwork', size: number_of_records_per, offset: offset, published: 'true'}.reverse_merge(params)).parse
      # whole = api.search({q: "#{query}type=artwork", size: number_of_records_per, offset: offset}.reverse_merge(params))
     
      results = parse_results(response["_embedded"]["results"])

      if results.any? || response["total_count"] <= offset+number_of_records_per
        if results.empty?
          error_response
        else 
          results
        end
      else
         
        offset = offset+number_of_records_per
        search(query, {offset: offset})
      end
    # rescue Faraday::Error::ResourceNotFound => e
    #   # error_response(e.message)
    # rescue Faraday::ClientError => e
    #   # error_response
    # end
  end
  
  # this isn't really getting all works - need to add pagination
  def all_works
    works = api.get(ARTWORK_ENDPOINT)
    works.parse["_embedded"]["artworks"]
  end

  #  #find is a better name or find_artwork
  def single_listing(listing_id)
     artwork_query = api.get(ARTWORK_ENDPOINT + '/' + listing_id)
     # So, sometimes the contnet_type isn't set? That's odd
    #  p "Artwork query content type: #{artwork_query.content_type}"
     artwork = artwork_query.parse
    unless artwork["title"].nil?
      artwork
     else 
      error_response(artwork['message'])
     end

  end
  
  def artist_works(artist_id)
    response = api.follow.get("https://api.artsy.net/api/artworks/", params: {artist_id: artist_id}).parse
    response["_embedded"]["artworks"]
  end
  
  def art_name(art)
    art["title"]
  end
  
  def art_creator(art)
    artist_link = api.get(art["_links"]["artists"]["href"])
    artist_response = artist_link.parse
    artist = artist_response["_embedded"]["artists"]
    artist.map{|a| a["name"]}.to_sentence
  end
  
  def art_description(art)
    # I'm going to want to concat some stuff here,
    # the medium, the collecting_institution and perhps additional_information and image_rights

    art["blurb"]
  end
  
  def art_release_date(art)
    art["date"]
  end
  
  def art_image(url, image_version='medium')
    if url.class == Hash
      url = url["_links"]["thumbnail"]["href"]
    end
    "#{url.split(/\/\w+.jpg$/)[0]}/#{image_version}.jpg"
  end
  
  def art_images(art)
    art["image_versions"].map{ |version| art_image(art["_links"]["thumbnail"]["href"], version)}
  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art["_links"]["thumbnail"]["href"])]
  end
  
  def art_source
    VALID_GATEWAYS.key("ArtsyGateway")
  end
  
  def art_source_link(art)

    art["_links"]["permalink"]["href"]
  end
  
  def art_category(art)
    "Visual Arts"
  end
  
  def links_for_resource(resource)
    resource["_links"]
  end
  

  def token
    @token ||= AuthorizationToken.artsy
  end
  
  def renew_token
    api_url = URI.parse('https://api.artsy.net/api/tokens/xapp_token')
    response = Net::HTTP.post_form(api_url, client_id:  ENV['artsy_client_id'], client_secret: ENV['artsy_client_secret'])
    
    xapp_token = JSON.parse(response.body)['token']
    expires_on = JSON.parse(response.body)['expires_at']

    if token.present?
      token.update(token: xapp_token, expires_on: expires_on)
    else
      AuthorizationToken.create(service: "artsy", token: xapp_token, expires_on: expires_on) 
    end
  end

  def valid?
    !items.any?{|item| item == false} 
  end
  
  private
  
  def api(renewing=false)
    headers = {
      accept: 'application/vnd.artsy-v2+json'
    }
    if renewing 
      headers[:content_type] = "application/json" 
    else
      headers['X-Xapp-Token'] = token.token
    end

    HTTP.headers("Accept": "application/vnd.artsy-v2+json", "X-Xapp-Token": token.token)
  
  end
  
  def guaranteed_items
    [listing_id, listing_ids].compact.flatten(1) 
  end
  
  def parse_results(results)
    results.map do |result|
      id = result_id(result)
      thumbnail_url = result_thumbnail(result)
      
      next unless id && thumbnail_url
      {
        title: result["title"],
        id: id,
        image: art_image(thumbnail_url),
        type: result["type"]
      }  
   end.compact
  end
  
  def error_response(message="No Results Found!")
    @errors << message
    false 
  end

  def result_id(result)
    available = api.get(result["_links"]["self"]["href"]).code != 404
    available && result["_links"]["permalink"] && result["_links"]["permalink"]["href"].split("/").last
  end

  def result_thumbnail(result)
    result["_links"].has_key?("thumbnail") && result["_links"]["thumbnail"] != "/assets/shared/missing_image.png" &&  result["_links"]["thumbnail"]["href"]
  end
  
end
