class DiscogsGateway
  attr_reader :wrapper, :listing_id, :listing_ids, :artist_id
  attr_accessor :errors
  def initialize(params={})
    @listing_id = params[:listing_id]
    @listing_ids = params[:listing_ids]
    @artist_id = params[:artist_id]
    @errors = []
  end
  
  def items
    if artist_id
      artist_works(artist_id).releases
    else
      guaranteed_items.map {|listing_id| single_listing(listing_id) }.compact
    end
  end

  
  def single_listing(release_id)
    # this is bad, mkay
    sleep 1
    begin
      wrapper.get_release(release_id)
    rescue Discogs::UnknownResource
      @errors = ["No Results Found!"]
      false
    end
    
  end

  # single item methods
  # and most likely to be used by the Importer
  # grab art param from #single_listing above
  
  def art_creator(art)
    art.artist || art.artists.map(&:name).to_sentence
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
    art.images.first.uri if art.images
  end
  
  def art_images(art)
    art.images.map(&:uri) if art.images
  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art)] if art.images
  end
  
  def art_category(art)
    "Music"
  end
  
  def art_source
    "Discogs.com"
  end
  
  def art_source_link(art)
    art.uri
  end
  
  def art_other(art)
    {
      'videos' => art.videos.map(&:uri),
      'genres' => art.videos.genres.join(", "),
      'extra_artists' => art.extraartists.map(&:name),
      'source_uri' => art.uri
    }
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
    else
      search_type = "release"
    end
    params.delete(:search_type)
    results = wrapper.search(query, {type: search_type}.reverse_merge(params)).results.map {|r| r.image = r.delete(:thumb); r}
    results.empty? ? {error: 'No results found!'} : results
  end
  
  # good way to get release_ids
  def artist_works(artist_id)
    wrapper.get_artist_releases(artist_id)
  end
  
  # not sure if I'll use this (especially since it's repeating #art_name)
  def artist_names(search_result)
    search_result.artists.map(&:name).join
  end
    
  # renamed to api in other Gateways
  def wrapper
    @wrapper ||= Discogs::Wrapper.new(ENV['discogs_app_name'], user_token: ENV['discogs_user_token'])
  end
  
  
  # if any items have return false, 
  # the gateway is not valid
  def valid?
    !items.any?{|item| item == false}
  end


  private
  
  def guaranteed_items
    [listing_id, listing_ids].compact.flatten(1)
  end
  
  
end