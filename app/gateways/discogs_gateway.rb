# I need a better way to fetch a bunch of listings
# I shouldn't be hitting my rate limits, but yet...

# You could stub, but in the real world....
class DiscogsGateway
  attr_reader :wrapper, :listing_id, :listing_ids, :artist_id

  def initialize(params={})
    @listing_id = params[:listing_id]
    @listing_ids = params[:listing_ids]
    @artist_id = params[:artist_id]
  end
  
  def items
    if artist_id
      artist_works(artist_id).releases
    else
      guaranteed_items.map {|listing_id| single_listing(listing_id) }.compact
    end
  end

  
  def single_listing(release_id)
    # byebug
    # begin
    sleep 1
    release = wrapper.get_release(release_id)      
    release

    # rescue Discogs::UnknownResource
      # wrapper.get_master_release(release_id)
    # rescue Discogs::UnknownResource
    # end
  end

  # single item methods
  # and most likely to be used by the Importer
  # grab art param from #single_listing above
  
  def art_creator(art)
    art.artist || art.artists.map(&:name).join
  end
  
  def art_release_date(art)
    art.released
  end
  
  def art_name(art)
    art.title
  end
  
  def art_description(art)
    art.notes
  end
  
  def art_image(art)
    art.images.first.uri
  end
  
  def art_images(art)
    art.images.map(&:uri)
  end
  
  # good way to get release ids
  def search(query, params={})
    case params[:search_by]
    when 'release'
      search_type = 'artist'
    when 'master'
     search_type = 'release'
    when 'artist'
     search_type = 'master'
    end
    params.delete(:search_type)
    wrapper.search(query, {type: search_type}.reverse_merge(params)).results
  end
  
  # good way to get release_ids
  def artist_works(artist_id)
    wrapper.get_artist_releases(artist_id)
  end
  
  # not sure if I'll use this (especially since it's repeating #art_name)
  def artist_names(search_result)
    search_result.artists.map(&:name).join
  end
  
  
  def wrapper
    @wrapper ||= Discogs::Wrapper.new(ENV['discogs_app_name'], user_token: ENV['discogs_user_token'])
  end
  private
  
  def guaranteed_items
    [listing_id, listing_ids].compact.flatten(1)
  end
  
  
end