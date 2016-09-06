class DiscogsGateway
  attr_reader :wrapper

  def initialize
    @wrapper ||= Discogs::Wrapper.new(ENV['discogs_app_name'], user_token: ENV['discogs_user_token'])
  end
  
  def single_listing(release_id)
    @wrapper.get_release(release_id)      
  end

  # single item methods
  # and most likely to be used by the Importer
  # grab art param from #single_listing above
  
  def art_creator(art)
    art.artists.map(&:name).join  
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
    if params.has_key? :artist
      search_type = 'artist'
      params.delete(:artist)
    end 
    @wrapper.search(query, {type: search_type}.merge(params))
  end
  
  # good way to get release_ids
  def artist_works(artist_id)
    @wrapper.get_artist_releases(artist_id)
  end
  
  # not sure if I'll use this (especially since it's repeating #art_name)
  def artist_names(search_result)
    search_result.artists.map(&:name).join
  end
  
  
end