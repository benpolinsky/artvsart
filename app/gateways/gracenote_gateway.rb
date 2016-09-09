class GracenoteGateway
  attr_reader :listing_id, :listing_ids

  def initialize(params={})
    @listing_id = params[:listing_id]
    @listing_ids = params[:listing_ids]
    @artist_id = params[:artist_id]
  end
  
  def items
  end
  
  def single_listing(release_id)  
  end
  
  def art_creator(art)   
  end
  
  def art_release_date(art)
  end
  
  def art_name(art)
  end
  
  def art_description(art) 
  end
  
  def art_image(art)
  end
  
  def art_images(art)
  end
  
  # good way to get release ids
  def search(query, params={})
  end
  
  # good way to get release_ids
  def artist_works(artist_id)
  end
  
  # not sure if I'll use this (especially since it's repeating #art_name)
  def artist_names(search_result)
  end


end