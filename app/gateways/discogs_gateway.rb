class DiscogsGateway < AbstractGateway
  attr_reader :artist_id
  
  def initialize(params={})
    super
    @artist_id = params[:artist_id]
  end
  
  def items
    artist_id ? artist_works(artist_id).releases : super
  end

  def single_listing(release_id)
    begin
      api.get_release(release_id)
    rescue Discogs::UnknownResource
      error_response
    end
  end
  
  def art_creator(art)
    art.artist || art.artists.map(&:name).to_sentence
  end
  
  def art_release_date(art)
    art.released
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
  
  def art_category(art)
    "Music"
  end
  
  def art_source
    VALID_GATEWAYS.key("DiscogsGateway")
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
    results = api.search(query, {type: search_type}.reverse_merge(params)).results.map {|r| r.image = r.delete(:thumb); r}
    results.empty? ? error_response : results
  end
  
  # good way to get release_ids
  def artist_works(artist_id)
    api.get_artist_releases(artist_id)
  end
  
  # not sure if I'll use this (especially since it's repeating #art_name)
  def artist_names(search_result)
    search_result.artists.map(&:name).join
  end
    

  def api
    @api ||= Discogs::Wrapper.new(ENV['discogs_app_name'], user_token: ENV['discogs_user_token'])
  end
  
  
  def valid?
    !items.empty? && super
  end

  
end