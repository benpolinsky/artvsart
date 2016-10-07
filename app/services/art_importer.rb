# while the dependency injection is nice,
# it would be nice for users to be able
# to initialize an importer like so:

#    ArtImporter.new(:artsy, listing_id)

# in addition to:

#    ArtImporter.new(artsy_gateway, listing_id)


class ArtImporter
  attr_reader :gateway
  
  def initialize(gateway)
    @gateway = gateway
  end

  # knows a bit too much...
  # perhaps it should be:
  
  # Art.create(gateway.prepared_items([field_list]))

  # then each gateway:
  # def prepare_item(art)
  #  {
  #    name: art_name(art)
  #  }
  # end
  #
  # That probably makes more sense...
  def import
    gateway.items.each do |item|
      import_item(item)
    end
  end
  

  def import_item(item)
    Art.create({
      name: gateway.art_name(item),
      creator: gateway.art_creator(item),
      image: gateway.art_image(item),
      description: gateway.art_description(item),
      source: gateway.art_source,
      additional_images: gateway.art_additional_images(item)
    })
  end
end