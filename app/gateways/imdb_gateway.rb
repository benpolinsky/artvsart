class IMDBGateway < AbstractGateway
  
  def single_listing(id)
    result = OMDB.id(id) 
    if result[:error]
      error_response("Incorrect IMDb ID.")
    else
      result
    end
  end

  def search(query, params={})
    results = [OMDB.search(query)].flatten(1)
    if results.first[:response] == "False"
      error_response('No Results!')
    else
      results.map do |art|
        art[:image] = art.delete(:poster)
        art[:id] = art.delete(:imdb_id)
        art[:name] = art.delete(:title)
        art
      end
    end
  end

  def art_image(art)
    art[:poster]
  end
  
  def art_images(art)
    [art[:poster]]
  end
  
  def art_creator(art)
    art.director
  end
  
  def art_release_date(art)
    art.year
  end
  
  def art_description(art)
    art.plot
  end
  
  def art_category(art)
    art.type == "movie" ? "Movie" : "TV Show or Series"
  end
  
  def art_source_link(art)
    "https://www.imdb.com/title/#{art.imdb_id}"
  end
  
  def art_other(art)
    {
      'actors' => art.actors,
      'writer' => art.writer
    }
  end

end