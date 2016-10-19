class ArtImporter
  attr_reader :gateway
  
  def initialize(gateway)
    @gateway = gateway
  end


  def import
    gateway.items.each do |item|
      import_item(item)
    end
  end
  
  # And now we have another dependency in Category
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
end