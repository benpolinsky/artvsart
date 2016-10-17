class NullCategory < Category
  def self.new
    @cat ||= super 
  end
  
  def arts
    Art.none
  end
  
  def slug 
    ""
  end
  
  def color
    ""
  end
end
