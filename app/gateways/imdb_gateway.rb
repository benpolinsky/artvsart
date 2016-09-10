class IMDBGateway
  attr_accessor :id, :ids
  
  def initialize(params={})
    @id = params[:id]
    @ids = params[:ids]
  end
  
  def items
    if id
      [single_listing(id)]
    else
      ids.map {|id| single_listing(id)}
    end
  end
  
  def single_listing(id)
    OMDB.id(id)
  end
  
  def search(query, params={})
    OMDB.search(query)
  end
  
  def image(art)
    art.poster
  end
  
  def images(art)
    [art.poster]
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
  
  def id
    @id
  end

end