class ArtImporter
  attr_reader :gateway
  attr_accessor :errors
  
  def initialize(gateway)
    @gateway = gateway
  end


  # if the gateway is valid, ask it for its for items and import each
  # otherwise we'll store errors and return false
  
  def import

    if gateway.valid?
      gateway.items.map do |item|
        import_item(item)
      end
    else
      @errors = gateway.errors
      false
    end
  end
  
  # ask the gateway for a bunch of properties
  # and create an Art from them

  def import_item(item)
    Art.create({
      name: gateway.art_name(item),
      creator: gateway.art_creator(item),
      image: gateway.art_image(item),
      description: gateway.art_description(item),
      source: gateway.art_source,
      source_link: gateway.art_source_link(item),
      additional_images: gateway.art_additional_images(item),
      category: Category.find_or_create_by(name: gateway.art_category(item))
    })
  end
  
  # Refactoring ideas for less dependencies (Art, knowing each gateway's art_*)
  # Alternative: Art.create(gateway.prepare_item(item))
  # or: 
  # initialize(gateway, import_to) and then:
  # import_to.safe_constantize.create(gateway.prepare_item)
  
  # in the latter we still have knoweldge of import_to#create...
end