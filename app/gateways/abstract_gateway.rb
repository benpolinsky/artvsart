class AbstractGateway
  attr_reader :api
  attr_accessor :listing_id, :listing_ids, :guaranteed_ids, :errors
  
  def initialize(params={})
    @listing_id             = params[:listing_id]
    @listing_ids            = params[:listing_ids]
    @guaranteed_ids = ([listing_id]+[listing_ids]).flatten(1).compact
    @errors = []
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)}
  end
  
  def single_listing(id)
    # please implement
  end

  def search(query, params={})
    # please implement
  end

  # the following methods need to be implemented
  # for each art to be successfully imported
  
  def art_image(art)

  end
  
  def art_images(art)

  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art)]
  end
  
  def art_creator(art)

  end
  
  def art_release_date(art)

  end
  
  def art_name(art)
    art.title
  end
  
  def art_description(art)

  end
  
  def art_category(art)
    "Unclassified"
  end
  
  def art_source
    "Unknown"
  end
  
  def art_source_link(art)
    
  end
  
  def valid?
    !items.any?{|item| item == false} 
  end
  
  private
  
  def api
  
  end
  
  
  def error_response(message="No Results Found!")
    @errors << message
    @errors.uniq!
    false
  end

end