
require 'hyperclient'

class ArtsyGateway
  ARTSY_TOKEN = ENV['artsy_token']
  ARTSY_ENDPOINT = 'https://api.artsy.net/api'
  
  attr_accessor :listing_id, :listing_ids, :api
  
  def initialize(params={})
    @listing_id  = params[:listing_id]
    @listing_ids = params[:listing_ids]
  end
  
  def items
    guaranteed_items.map{|listing_id| single_listing(listing_id) }
  end


  def search(query, params={})
    # api.search(q: 'andy').results.first.self => to access attributes
    # size: 10 to be explicit 

    offset = params[:offset] ? params[:offset] : 0
    begin
      whole = api.search({q: query, size: 10, offset: offset, total_count: 1}.reverse_merge(params))
      results = parse_results(whole.self)
      if results.any? || whole.self.total_count <= offset+10
        results
      else
        offset = offset+10
        self.search(query, {size: 10, offset: offset, total_count: 1}.reverse_merge(params))
      end
    rescue Faraday::ClientError => e
      puts e
    end
  
  end
  
  # this isn't really getting all works - need to add pagination
  def all_works
    works = api.artworks(total_count: 1)
    works.artworks
  end

  #  #find is a better name or find_artwork
  def single_listing(listing_id)
    api.artwork(id: listing_id)
  end
  
  def artist_works(artist_id)
    works = api.artist(id: artist_id).artworks(total_count: 1)
    works.artworks
  end
  
  def art_name(art)
    art.title
  end
  
  def art_creator(art)
    art.artists.map(&:name).join  
  end
  
  def art_description(art)
    # I'm going to want to concat some stuff here,
    # the medium, the collecting_institution and perhps additional_information and image_rights
    art.blurb
  end
  
  def art_release_date(art)
    # date is a range or a year...
    # we could keep everything as a string and pass it on to views
    # but then we lack any query ability
    art.date
  end
  
  def art_image(art, image_version='medium')
    "#{art.image._url.split(".jpg")[0]}#{image_version}.jpg"
  end
  
  def art_images(art)
    art.image_versions.map{ |version| art_image(art)}
  end
  
  def links_for_resource(resource)
    resource._links
  end
  
  def api
    @api ||=
      Hyperclient.new(ARTSY_ENDPOINT) do |api|
        api.headers['Accept'] = 'application/vnd.artsy-v2+json'
        api.headers['X-Xapp-Token'] = ARTSY_TOKEN

        api.connection(default: false) do |conn|
          conn.use FaradayMiddleware::FollowRedirects
          conn.use Faraday::Response::RaiseError
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter :net_http
        end
      end

  end
  
  private
  
  def guaranteed_items
    [listing_id, listing_ids].compact.flatten(1) 
  end
  
  def parse_results(whole)
    whole.results.map do |result|
     begin
       next unless result.type == 'Artwork' && result.self.id.present?
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