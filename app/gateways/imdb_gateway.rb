class IMDBGateway
  attr_accessor :id, :ids, :guaranteed_ids
  
  def initialize(params={})
    @id             = params[:listing_id]
    @ids            = params[:listing_ids]
    @guaranteed_ids = ([id]+[ids]).flatten(1).compact
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)}
  end
  
  def single_listing(id)
    OMDB.id(id)
  end

  def search(query, params={})
    results = [OMDB.search(query)].flatten(1)
    if results.first[:response] == "False"
      {error: results.first[:error]}
    else
      results.map do |art|
        art[:image] = art.delete(:poster)
        art[:id] = art.delete(:imdb_id)
        art
      end
    end
  end


  # all used by ProductImporter to access
  # an individual piece of art's info
  # extract_class and delegate_class?
  # Not sure...
  def art_image(art)
    art[:image]
  end
  
  def art_images(art)
    [art[:image]]
  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art)]
  end
  
  def art_creator(art)
    art.director
  end
  
  def art_release_date(art)
    art.year
  end
  
  def art_name(art)
    art.title
  end
  
  def art_description(art)
    art.plot
  end
  
  def art_category(art)
    art.type == "movie" ? "Movie" : "TV Show or Series"
  end
  
  def art_source
    "IMDB.com"
  end
  
  def art_other(art)
    {
      'actors' => art.actors,
      'writer' => art.writer
    }
  end
  

end