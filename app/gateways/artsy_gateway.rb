# This Gateway isn't suitable for production use.
# It's goal is to target published artwork with images

# Possibility I'm missing something, but neither 
# Artsy's Artwork endpoint, nor its genes allow for search terms

# Thus we're forced to go through the generalized, google-backed, search.

# Most of the artwork (which we can thankfully target
# through +more:pagemap:metatags-og_type:artwork)
# isn't published, and AFAIK you can't query that aspect.

# Thus, we're forced to check for an ID (denotes published)
# which creates another request as the ID isn't return
# without calling #self on the hyperclient record returned.

# In addition, there's a size limit of 10 records per query.
# Often a query will return a total_count of thousands...

# It seems ridiculous, as none of the other apis utilized
# in this app have similar limitations.  The APIs range from
# Google to Discogs.com, Harvard Art Museum (all sizes of operation, is my point),
# and are implemented using REST to various degrees of 'psuedo'-REST.

# Sigh.


require 'hyperclient'

class ArtsyGateway < AbstractGateway
  ARTSY_ENDPOINT = 'https://api.artsy.net/api'

  def initialize(params={})
    super
    renew_token if !token || token.expiring_soon?
  end
  

  def search(query, params={})
    offset = params[:offset] ? params[:offset] : 0
    number_of_records_per = 10
   
    searcher = ArtsySearcher.new({
      query: query,
      number_of_records_per: number_of_records_per,
      offset: offset,
      api: api,
      params: params
    })
    
    begin
      searcher.find_results
      if searcher.errors || !searcher.results?
        error_response
      else
        searcher.results.results
      end
      
    rescue Faraday::Error::ResourceNotFound => e
      error_response(e.message)
    rescue Faraday::ClientError => e
      error_response
    end
  end
  
  # this isn't really getting all works - need to add pagination
  def all_works
    works = api.artworks(total_count: 1)
    works.artworks
  end

  def single_listing(listing_id)
    begin
     artwork = api.artwork(id: listing_id)
     artwork.title # to see if we've found anything
     artwork
    rescue Faraday::Error::ResourceNotFound => e
      error_response
    end
  end
  
  def artist_works(artist_id)
    works = api.artist(id: artist_id).artworks(total_count: 1)
    works.artworks
  end

  def art_creator(art)
    art.artists.map(&:name).to_sentence  
  end
  
  def art_description(art)
    art.blurb
  end
  
  def art_release_date(art)
    art.date
  end
  
  def art_image(art, image_version='medium')
    "#{art.image._url.split(".jpg")[0]}#{image_version}.jpg"
  end
  
  def art_images(art)
    art.image_versions.map{ |version| art_image(art)}
  end
  
  def art_source_link(art)
    art.permalink.to_s
  end
  
  def art_category(art)
    "Visual Arts"
  end
  
  def links_for_resource(resource)
    resource._links
  end
  

  def token
    @token ||= AuthorizationToken.artsy
  end
  
  def renew_token
    response = api(true).tokens.xapp_token._post(client_id: ENV['artsy_client_id'], client_secret: ENV['artsy_client_secret'])

    if token.present?
      token.update(token: response.token, expires_on: response.expires_at)
    else
      AuthorizationToken.create(service: "artsy", token: response.token, expires_on: response.expires_at) 
    end
  end
  
  private
  
  def api(renewing=false)
      Hyperclient.new(ARTSY_ENDPOINT) do |api|
        api.headers['Accept'] = 'application/vnd.artsy-v2+json'
        if renewing
          api.headers['Content-Type'] = 'application/json' 
        else
          api.headers['X-Xapp-Token'] = token.token
        end


        api.connection(default: false) do |conn|
          conn.use FaradayMiddleware::FollowRedirects
          conn.use Faraday::Response::RaiseError
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter :net_http
        end
      end
  end
    
  def parse_results(whole)
    whole.results.map do |result|
     begin
       next unless result.self.id.present?
      {
        title: result.title,
        id: result.self.id,
        image: art_image(result.self),
        type: result.type
      }  
     rescue Faraday::ResourceNotFound => e
     end
   end.compact
  end
  
end
