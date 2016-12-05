# Simple simple.
# Gimme a Gateway.
# I'll see if it's valid
# and ask it for its item's properties
# Then I'll save em in an Art, see?

class ArtImporter
  attr_reader :gateway
  attr_accessor :errors
  
  def initialize(gateway)
    @gateway = gateway
  end
  
  def import
    if gateway.valid?
      art = gateway.all_art_properties
      Art.create(art)
    else
      @errors = gateway.errors
      false
    end
  end  

  def import_item(item)
    Art.create(gateway.art_properties(item))
  end
  
end