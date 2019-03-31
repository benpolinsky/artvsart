class IMDBGateway
  attr_accessor :id, :ids, :guaranteed_ids, :errors
  
  def initialize(params={})
    @id             = params[:listing_id]
    @ids            = params[:listing_ids]
    @guaranteed_ids = ([id]+[ids]).flatten(1).compact
    @errors = []
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)}
  end
  
  def single_listing(id)
    result = api.find_by_id(id) 
    if result.error
      error_response
    else
      result
    end
  end

  def search(query, params={})
    
    results = api.search(query)
    if !results.methods.include?(:movies)
      error_response('No Results!')
    else
      results.movies.map do |art|
        {
          image: art.poster,
          id: art.imdbid,
          title: art.title
        }

      end
    end
  end


  # all used by ProductImporter to access
  # an individual piece of art's info
  # extract_class and delegate_class?
  # Not sure...
  def art_image(art)
    art.poster
  end
  
  def art_images(art)
    [art.poster]
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
    VALID_GATEWAYS.key("IMDBGateway")
  end
  
  def art_source_link(art)
    "https://www.imdb.com/title/#{art.imdbid}"
  end
  
  def art_other(art)
    {
      'actors' => art.actors,
      'writer' => art.writer
    }
  end
  
  def valid?
    !items.any?{|item| item == false} 
  end
  
  def error_response(message="Incorrect IMDb ID.")
    @errors << message
    false
  end

  private
  def api
    Omdb::Api::Client.new(api_key: ENV['omdb_key'])
  end

end