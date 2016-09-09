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
  
  def import
    gateway.items.each do |item|
      import_item(item)
    end
  end
  
  def import_item(item)
    Art.create({
      name: gateway.art_name(item),
      creator: gateway.art_creator(item)
    })
  end
end