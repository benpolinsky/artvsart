# A Gateway Must Implement:

# 1. #search which takes a query and returns an enum. of records
# 2. #single_listing which takes an id or path and returns a single record

# In addition, each Gateway must implement methods to extract information
# from each record.  

# These methods are prefixed with art_
class AbstractGateway
  attr_reader :api
  attr_accessor :listing_id, :listing_ids, :guaranteed_ids, :errors
  
  def initialize(params={})
    @listing_id             = params[:listing_id]
    @listing_ids            = params[:listing_ids]
    

    # I thought the splat '*' could do this job,
    # But it turns hashes into array of arrays
    # and funky stuff with strings
    @guaranteed_ids = ([listing_id]+[listing_ids]).flatten(1).compact
    @errors = []  
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)}
  end
  

  def valid?
    validate!
    @errors.none?
  end
  
  def single_listing(id)
    # please implement
  end

  def search(query, params={})
    # please implement
  end

  # the following methods need to be implemented
  # for each art to be successfully imported
  def art_name(art)
    art.title
  end
  
  def art_source
    VALID_GATEWAYS.key "#{self.class.name}"
  end
  
  def art_category(art)
    "Unclassified"
  end
  
  
  def art_id(art)
    art.id
  end
  
  def art_image(art)
    # please implement
  end
  
  def art_images(art)
    # please implement 
  end
  
  def art_additional_images(art)
    [art_images(art)].flatten(1).compact - [art_image(art)]
  end
  
  def art_creator(art)
     # please implement 
  end
  
  def art_release_date(art)
     # please implement
  end
  
  def art_description(art)
     # please implement
  end
  
  def art_source_link(art)
    # please implement
  end
  
  # the Category still stinks...
  def art_properties(art)
    {
      name: art_name(art),
      creator: art_creator(art),
      image: art_image(art),
      description: art_description(art),
      source: art_source,
      source_link: art_source_link(art),
      additional_images: art_additional_images(art),
      category: Category.find_or_create_by(name: art_category(art)),
      creation_date: art_release_date(art)
    }
  end
  
  def all_art_properties
    items.map do |item|
      art_properties(item)
    end
  end
  
  def search_properties(art)
    [art].flatten(1).compact.map do |a|
      {
        name: art_name(a),
        creator: art_creator(a),
        image: art_image(a),
        id: art_id(a)
      }
    end
  end
  
  private
  
  def api
    # please implement
  end
  
  
  def error_response(message="No Results Found!")
    @errors << message
    @errors.uniq!
    false
  end

  def validate!
    @errors << 'Please provide a listing id or ids' if @guaranteed_ids.none?
    items
  end

end